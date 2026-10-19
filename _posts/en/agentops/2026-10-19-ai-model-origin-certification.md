---
title: "The Day a Model Became a Part Asked for a Certificate of Origin"
excerpt: "KIC's in-house AI usage dropped 78.7% in four months, and a 900 million won GPU expansion was signed in the same period. The point at which a model's 'origin' starts being written on the procurement spec sheet in the export control era."
seo_title: "The Day a Model Needs a Certificate of Origin, the Missing Fields in the Spec Sheet That KIC's 798 Requests Told About"
seo_description: "While KIC's in-house AI usage plunged 78.7%, a 900 million won GPU expansion was contracted. An analysis that in the U.S.-China export control era, model origin and execution governance are starting to be written on the procurement spec sheet."
date: 2026-10-19
last_modified_at: 2026-10-19
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
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/ai-model-origin-certification/"
---

![Image visualizing the concept of the day a model became a part asked for a certificate of origin](/assets/images/ai-model-origin-certification-hero.webp)
*A visual of the post's core concept.*

## A Three-Line Spec Sheet

Korea Investment Corporation, KIC for short, had a three-line model evaluation sheet. Accuracy, cost efficiency, multilingual suitability. Nothing beyond that was written. Fields like the developer's country of origin or sanctions-list status did not even exist.

KIC manages 339 trillion won in sovereign assets. Yet of its four in-house AI models, the language model was Alibaba's Qwen3 and the search embedding model was BAAI's BGE-M3, which sits on the U.S. export control list. The Power reported this, security concerns followed, and Rep. Kang Nung-guk called for AI security standards for public institutions. The criticism flew at the model's "origin," not its performance.

Then the books were opened. In-house AI usage fell from 3,755 requests in May to 798 in September, down 78.7% in four months. In the same month, staff used outside ChatGPT 36,881 times, roughly 46x the in-house AI. And signed right at that moment was a 950 million won expansion that grows the GPUs from 4 to 12. A fund managing 339 trillion won added hardware while usage collapsed.

## The 798 Requests Were Not a Performance Problem

It is quick to blame the model. Staff did not avoid the internal AI because it was slow or inaccurate. The issue was what the "name tag" of the model they were supposed to use said. For an institution handling sovereign assets, users feeling uneasy about a model from the export control list is a natural reaction, performance aside. The controversy broke in that direction, and the usage ledger quietly recorded the answer.

The hardware kept growing in the meantime. A 900 million won expansion was signed while usage fell 78.7%, which shows this organization had answered the question of "compute" but not the question of "governance." This first-generation in-house AI adoption, which picked models on performance and price alone, is the representative case of the governance gap it exposed. The real bottleneck in AI adoption was not the number of GPUs. It was whether the organization could answer the question of under whose control it ran, and with whose approval.

If the controversy drags on, the next questions will follow. For a budget that adds hardware while usage falls, the expectation is that performance evaluation standards for public AI budgets will be strengthened in the same cycle. Developer nationality, export control list status, and data flow are expected to harden into mandatory pre-adoption checks, and security and sovereign elements are likely to be written explicitly into the AI adoption review criteria of public and financial institutions. The principle that even a published open-source model should run only in a controlled execution environment, where source code verification and post-hoc patch management are possible, is spreading alongside it. In other words, this incident is not a story that ends with one institution's mistake. It is the moment when the industry's procurement standards are being quietly rewritten.

## The World KIC Could Not Wait For

The world was already rewriting its procurement documents. On October 16, China's Ministry of Commerce and Ministry of Science and Technology released a draft revision adding 23 AI sub-technologies to the export ban and restriction list, covering foundation models, AI agents, and chip design. The quantitative criterion reported by Global Economic was models reaching 2 trillion or more parameters and 10^26 FLOPs of training compute. Commercial services in the form of an official API or cloud SaaS aimed at overseas customers are an exception, but lifting weights onto overseas clouds now carries a pre-approval burden. It is assessed as precise regulation that "locks the source code and leaves the commercial platform open." The draft's background is Meta's 2 billion dollar acquisition of Manus, forcibly terminated in July on national security grounds. The Australian Strategic Policy Institute warned that it is opaque how the "approve immediately upon application" principle will be implemented inside bureaucratic administration, and that the compliance burden could delay Chinese AI companies' entry into the global cloud supply chain. If global cloud access for Chinese open-weight models such as Kimi and GLM shrinks, the conditions for domestic companies using low-price models change, and sovereign AI demand could be reorganized toward U.S. and Korean models.

The U.S. side is moving too. The Kyunghyang Shinmun defined the current situation as a "mutual weaponization" posture in which both sides restrict top-tier model access, including to allies. A PIIE researcher analyzed that even U.S. clouds, the main channel for Chinese models, could become subject to approval requirements, and a figure at the U.S. Congressional Foreign Affairs Association assessed that the U.S. will prepare a counter-framework. Ha Jeong-woo, deputy chair of the National AI Strategy Commission, warned that even open-weight new models may make the act of releasing one subject to a license, and that distillation training based on frontier models could become harder.

Korea's position is difficult. The top domestic model scores 47 on Artificial Analysis, a clear gap from the 61 to 63 of top U.S. models. Of next year's 4.7 trillion won frontier AI budget, 3.9 trillion won is allocated to Nvidia GPU purchases, drawing the point that it is "far from full-stack independence." In Q1 next year, the final two-team selection for Dokpamo (독파모) and the selection of frontier AI investment targets overlap, and it is assessed that the first test of the sovereign AI strategy will arrive. The Chosun Ilbo's exclusive report pointed out that in the 5 trillion won government-budget Korean sovereign AI project, more than half of the models actually adopted by civil servants and public institutions are foreign-made.

Signals from the tech industry point this way too. An analysis says open-weight models have actually gained power while the AI bubble debate covers the tech industry. According to Digital Today, Meta released Muse Spark Open, an 816 billion parameter model, and formed a local AI alliance with Apple, and Nvidia shipped Nemotron 3.5, an open model for agents. Companies that had run a multi-vendor strategy on Chinese open-weight models to optimize inference cost are now re-evaluating supply and control risk. The conditions for domestic startups and SMEs that had ridden low-price models change at this point as well. In an era when the strongest model's passport can change overnight, the question of "how do you control what you bring in" is moving from the security department to the procurement table.

## The Fab That Kept Its Models Inside

On the other hand, there are organizations that answered the same question differently. Samsung Electronics and France's Mistral AI are jointly developing a semiconductor-data-specialized model, and the operation is done on in-house infrastructure, not external cloud. The core of Social Value's reporting is that process data security comes first. Samsung is pushing an AI autonomous factory transition by introducing 50,000 or more Nvidia GPUs by 2030, and digital twin and OPC simulation performance will improve 20x. The DSEP platform already has 60 or more equipment vendors participating, and a process data sharing and AI-based equipment management ecosystem has become visible. Equipment partners are also setting AI software capabilities such as predictive maintenance as a new competition criterion beyond hardware performance. SK Hynix is investing 54 trillion won in the three pillars of its autonomous fab, targeting a 50% or more reduction in equipment maintenance and defect analysis time. The workflow structure is "humans judge, AI predicts." The AI proposes the cause and the countermeasure, and the engineer verifies and makes the final decision. The government increased the smart factory deployment budget by 70% to 402.1 billion won, supporting 30 autonomous factories and 400 manufacturing AI specialized smart factories. Attention is on whether the "humans judge, AI predicts" factory becomes the new standard of Korean manufacturing, and physical AI is expected to spread beyond semiconductors into batteries, shipbuilding, and manufacturing as a whole.

On the same battlefield, AWS productized a cloud operations agent. According to InfoQ's reporting, it is the promotion of the Well-Architected Tool, which had been an existing manual evaluation tool, into an agent-based service. The Well-Architected Agent preview automatically correlates resource configuration and usage metrics with application topology, generating recommendations close to architect-level judgment in bulk. It analyzes cost, security, elasticity, and performance across 65 or more AWS services, builds prioritized recommendations, and provides a CLI and IaC change package for each recommendation. The only access limits: it supports 3 U.S. regions and is exclusive to Business Support+ and above customers. Strands Box, which adds OS isolation and a policy language called Dogwood, was open-sourced as an agent sandbox that applies fine-grained behavior policies to multiple enforcement points such as network output, Shell, Python, and MCP broker. A policy like "3 Slack posts per 10 minutes max" or "block external HTTP after accessing the customer data directory" is no longer a developer's homework but a standard part. Practical questions of what 5,000 AWS partners should do are also flooding in. For organizations that must operate cloud inside a closed network, like finance and the public sector, this is also the moment when the limits of AWS-dependent agents surface. On the day the sandbox becomes the infrastructure, the procurer's question naturally shifts from "what is this model" to "under which policy does this model run, and where do those behavior records go."

## Four Fields to Add to the Spec Sheet

So what fields should be added to the three-line model procurement document? If the three-line criteria sheet was a procurement document of the awareness that "a model is a subscription service," what is needed now is a document of the awareness that "a model is a part."

The first is origin. The developer's nationality, sanctions list status, and the path the model takes into the organization. The second is execution location. Where the model runs, and whether data stays inside the fence. The third is behavior history. Who approved it, what happened, and whether those questions can still be answered afterward. The fourth is task assignment. Which model handles which work, at what cost.

These four questions overlap exactly with the targets ThakiCloud's Agent-Native Cloud Paxis handles as first-class resources. Because after the official product v1.1 GA, in Paxis, Skills, Tools, Policies, and Audit Logs are not attached options but baseline elements of execution. The models an agent can call are policy, every action leaves an audit log, and execution happens inside an isolated sandbox. Autonomy is managed as a governance scale from L0 to L3, per-task model selection via CostRouter is also a built-in feature, and it provides together ai-platform, a sovereign and on-premise Kubernetes deployment, and MCP connectors plus a skill market.

KIC's books, the 798 requests and the 46x, will remain in the industry as the first sample of the model procurement governance controversy. The era of choosing models on "cost efficiency" alone is over, in effect. The next KIC-style audit will not stop at the model. It will check which agents, on top of that model, access which tools and execute. The spec sheet is being rewritten. And the names of the newly created fields are the model's certificate of origin, and the execution governance built on top of it.

## References

This post was written by synthesizing the news below.

- The Power, [Korea Investment Corporation, Managing 339 Trillion Won, Loads Chinese Models into In-house AI... Security Concerns Raised](https://www.thepowernews.co.kr/view.php?ud=202610190734594307de3f0aa1be_7)
- Global Economic, ["Short-Term Bleeding vs. Long-Term Sovereign Defense"... China's "AI Export Lock" Shakes the Open-Weight Ecosystem](https://www.g-enews.com/view.php?ud=2026101821362522740c8c1c064d_1)
- Kyunghyang Shinmun, [Korea Caught in the U.S.-China AI Lock... The "Sovereign AI" Test](https://www.khan.co.kr/article/202610181724001)
- Social Value, [AI Catches Equipment Failures First... Semiconductor "Autonomous Fab" Competition in Full Swing](https://www.socialvalue.kr/news/view/1065596056818637)
- InfoQ, [AWS Reveals "Well-Architected Agent"... Agent Sandbox "Strands Box" Open-Sourced](https://www.infoq.com/news/2026/10/aws-well-architected-agent/)
- Digital Today, [[AI Hot Issue] AI Bubble Theory Sweeps the Tech Industry... Open-Weight AI Gaining Strength](https://www.digitaltoday.co.kr/news/articleView.html?idxno=707967)
