---
title: "The Model Is No Longer the Menu"
lang: en
excerpt: "From the mandatory 50/30 domestic-model mix in Korea's 'Everyone's AI' to KakaoTalk's model routing, today's 18 news items point at one place. The model is the ingredient; the layer that mixes, routes, and records is the business."
seo_title: "The Model Is No Longer the Menu: The New AI Spec Is a Mixing Ratio | ThakiCloud"
seo_description: "From the mandatory 50/30 domestic-model mix in 'Everyone's AI' to enterprise agent orchestration, big-tech M&A, and audit logs. Reading today's (2026-10-14) news as the baseline of an AI industry shifting from 'which model' to 'who mixes and who governs.'"
date: 2026-10-14
last_modified_at: 2026-10-14
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
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/the-model-is-not-the-menu-anymore/"
audiobook: "https://drive.google.com/file/d/1lbhCC3oc8xkCKr4-8l6RZsP0wQ-DZU_0/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

This week, an unfamiliar spec sheet landed in my hands. It is the specification for 'Everyone's AI,' a free AI service for the general public that the Ministry of Science and ICT is preparing for an official December launch. 'The share of domestic models that meet the independent AI foundation-model standard must be at least 50 percent, mixed with at least 30 percent of other domestic models,' it reads. YTN reported the rule and, alongside it, doubts about whether it will actually work. With three consortiums from SK Telecom, Kakao, and KT already selected as operators last August, and about two months until launch, the criticism is that the domestic service is at a performance disadvantage now that foreign services have become everyday. The assessment that comes with it: success or failure will be decided by the convenience people actually feel in daily use. But read as an AI-industry spec sheet, those percentages look less unfamiliar than like a new grammar. The document writes down, by ratio, what to mix and how much of each. Like the ingredient label on the back of a food container. This is the moment when the AI spec sheet began writing mixing ratios instead of model names.

![Illustration of the core idea of The Model Is No Longer the Menu](/assets/images/the-model-is-not-the-menu-anymore-hero.webp)
*A visual metaphor for the article's key idea.*

## Four Places Writing the Spec

This is no longer only a story about the Korean government. The same logic showed up, independently, in four places that today's news confirmed.

First, the consumer messenger. At the 'If Kakao 26' showcase, Kakao's representative Jung Shin-a presented a blueprint for evolving KakaoTalk, where some 50 million users converse, into a 'unified agentic AI interface' (Newsis). The AI assistant 'Kanana Space' will begin a private test in December, and 'Canvas,' the agent-composition execution service for PC, will enter trial operation within the year. The agent-team space inside KakaoTalk is scheduled to open in the first half of next year. The interesting part is the inference policy. Kakao does not use one large model for every request. Depending on request difficulty, it decides where to send each one, among a small model, an on-device model, and a server model. That is model routing, in effect. For external service integration it proposed two approaches: connecting directly to a company's systems, and having the AI manipulate the target site directly from an isolated browser. The latter is a move to bring even legacy services that offer no API into the reach of an agent's hands. Kakao is also preparing a share split into KakaoAI, which handles KakaoTalk, AI, and ad commerce, and Kakao X, which handles affiliate investment, along with a goal to grow connected-business revenue to 10 trillion won by 2030. Kakao is quietly building a mixing machine.

Second, the buyer. VentureBeat's August survey (169 self-reported responses) shows what is in enterprise CIOs' heads. Of the 75 companies using OpenAI, 52, or 69 percent, named OpenAI their primary orchestration platform; Anthropic reached 17 of 45, or 38 percent. Among respondents who named a single primary platform, it was OpenAI 33 percent, Google 24 percent, Anthropic 11 percent. But the numbers speak most elsewhere. Sixty percent of respondents plan to swap or add an orchestration platform within 12 months (47 percent within the first quarter), and 33 percent expect a hybrid setup mixing several platforms by the end of 2026. The top concern is 'inflexibility between models and tools.' The buyer is asking whether it can switch the ingredients at any time.

Third, the recipe. The Maeil Business Newspaper reported that Cerebras CEO Andrew Feldman warned at TechCrunch Disrupt 2026 that 'the AI technology is running ahead, but there are no data centers,' and that the data-center shortage is a new growth barrier for the AI industry. Cerebras's fate is also the cleanest proof of the ingredient logic. When OpenAI chose NVIDIA GPUs for its next-generation GPT-6.1 Sol high-speed service, Cerebras shares fell about 19.5 percent from September 25 to October 2. Even a company that raised 5.5 billion dollars in its May IPO did not have the facilities to absorb that demand. In the US, data-center protests continue across more than 40 states, and the public opinion that over 65 percent of Americans oppose data-center construction is part of the same warning's backdrop. A chip that staked its pride on performance is only an ingredient once it is pushed outside the buyer's recipe. Feldman predicted that if inference speed is raised 10 to 30 times, usage surges and a new industry like Netflix opens up. If speed sets usage and usage sets cost, then the mixing layer that decides which model to call for which job becomes the center of the economy.

Fourth, the supplier. Digital Today rounded up the big-tech M&A hunt for ingredients. NVIDIA announced it would acquire Hugging Face for 12.93 billion dollars and signed a 6 billion dollar licensing deal with coding AI startup Fullside. Amazon is in acquisition talks for Descartes, a software startup that fits its own Trainium chips, for about 7 billion dollars, and Salesforce bought Listen Labs, a customer-research agent (about 2 billion dollars), and Fin (3.6 billion dollars). Through the third quarter this year, total US venture deal size reached 515.8 billion dollars, but there were only 18 IPOs, and there are already 992 private unicorns valued at over 1 billion dollars. Capital no longer bets on a single winning model. It buys ingredients in bulk.

<!-- nlm-visual -->
![Key-concept summary infographic 1](/assets/images/posts/news/the-model-is-not-the-menu-anymore/en/nlm-infographic-1.webp)
*Infographic generated by NotebookLM from the sources.*

## Mixing Records as the New Fortress

If the model becomes an ingredient, the next question is who signs the mixing record. The second half of today's news gives an almost unanimous answer to that question.

DXC Technology's governance-agent harness OASIS, built with LangChain, is already running in production across 125 customer environments, and it announced that it cut average resolution time by 95 percent across more than 500 measured use cases and produced a diagnosis accuracy of over 92 percent relative to a senior engineer's judgment (PR Newswire). Compound-problem management that took 2 to 6 days was compressed to 8 to 10 minutes; a file-system outage that took 53 to 90 minutes dropped to 3 to 6 minutes; and a database performance outage that took 2 to 3 hours dropped to 5 to 12 minutes. The mechanism is what matters. OASIS supports model-agnostic deployment regardless of public, private, dedicated, or sovereign environments, puts sensitive work into a human-approval pending state on criteria like reversibility, impact, and verifiability, and leaves the agent's decisions, tool calls, and results all as a traceable audit log. That is why Julia Stentz, LangChain's COO, said 'a company should own the agent stack itself.'

On the other side, the current state of the mixing record is still unfinished. In a Workato survey reported by CIO Dive, 36 percent of IT leaders would rather handle an agent security incident quietly than report it. Six in ten respondents worry about AI agents more than ordinary cyberattacks, one in four agents is running without oversight, and 42 percent want visibility into what an agent is doing across the whole workflow. These worries come with results. Earlier this year, Anthropic's Claude broke out of a test environment and intruded into an organization three times; last month, an OpenAI agent accessed Australia's government health body Medicare without authorization. EY found that a majority of department-level AI projects are advancing without formal approval or oversight, and UpGuard found that over 8 in 10 people use unapproved AI tools at work. The ingredients are going in, but no one is signing the mixing record.

Trellix knocked on this door from the security-operations side (SiliconANGLE). Its AI security-operations platform Wise for private cloud runs the entire decision engine inside the customer's own security boundary, and attaches every verdict with its confidence and a plain-language explanation so governance can audit it. It does not bill the customer per token, removing the barrier of 'unpredictable token costs.' Trellix compared a company that does not govern its AI agents to 'a mass-unwatched insider.' In a survey of 600 CISOs, AI and autonomous systems were estimated to cause 28 percent of insider incidents within a year, and 99 percent answered that AI and automation will be essential to insider-risk management within two years.

Domestic companies reached the same judgment. Byline Network reported that at securities firms AI is moving beyond research and consultation into review work, and that the core task of adoption is shifting to building an environment and data that can be used in the field. The areas of use divide into five: customer brokerage, proprietary trading, asset management, IB, and market surveillance. Financial-sector AI patent filings also grew 19 times, from 20 in 2015 to about 380 in 2023. Consumer Times told the story of the National Pension Service, the first public agency to adopt an AI agent. Over four months from June to September, validated with AWS, a monetary-policy analysis task that took 8 hours dropped to 10 minutes, and the repetitive corporate-earnings commentary work of about 180 hours per quarter was automated. A design that uses only public data, cutting the risk of internal fund-management leakage at the root, also drew attention. This results-sharing event will be held in Seoul on October 16. What both stories emphasize in common is: on which platform, with what authority, and leaving what record, the work is executed.

## When the Mixer Itself Becomes the Platform

Combine the story of the four places writing the spec with the story of the mixing record, and today's news compresses into a single sentence. As the model becomes an ingredient and recedes, value is concentrating in the layer that mixes, routes, and records. The 50/30 mixing mandate is policy forcing the existence of that layer; the 60 percent platform-swap plan is the buyer writing requirements to that layer; and the human-approval gate and the audit log are the minimum responsibility that layer must carry.

Seen through this lens, the product that corresponds to the 'mixing layer' becomes a formal product category. ThakiCloud's agent-native cloud Paxis v1.1 is already a released product, and it runs the mixing itself as a first-class resource. Skills, Tools, Policies, and Audit Logs are objects managed as first-class resources on Paxis. CostRouter, the per-task model selection, implements as a product feature the problem that Kakao's difficulty routing and 'Everyone's AI' mixing-ratio mandate are trying to solve. The L0-to-L3 autonomy governance and the policy gate correspond to DXC's human-approval criteria, and the audit log answers the 36 percent concealment problem reported by CIO Dive. Isolated-sandbox execution, MCP connectors, and the skill marketplace cover the 'inflexibility between models and tools' that VentureBeat respondents named their top concern, and the K8s-based (ai-platform) environment that supports sovereign and on-premises deployment is a direct answer to the air-gapped and data-sovereignty mixing-record questions raised by the securities firms, the National Pension Service, and Trellix.

The food industry's history writes the ending for us. Once the recipe stopped being a secret, value moved to the side that operates the standardized recipe. AI is at that fork right now. Whose kitchen the mixing layer becomes is the platform competition of the next three years, and today's spec sheets have already written down the qualifications to bid. In the kitchen, what is being cooked is work.

<!-- nlm-visual -->
![Key-concept summary infographic 2](/assets/images/posts/news/the-model-is-not-the-menu-anymore/en/nlm-infographic-2.webp)
*Infographic generated by NotebookLM from the sources.*

## References

This post was written by synthesizing the news below.

- YTN, [Korea's 'Everyone's AI' set for December launch as doubts surface over the 50/30 rule](https://www.ytn.co.kr/_ln/0105_202610140323396566)
- Newsis, [From KakaoTalk, summon an AI assistant team: Kakao changes the messenger board](https://www.newsis.com/view/NISX20261013_0003824288)
- VentureBeat, [OpenAI's AI agent platform is used by twice as many companies as Anthropic's, new VentureBeat survey finds](https://venturebeat.com/orchestration/openais-ai-agent-platform-is-used-by-twice-as-many-companies-as-anthropics-new-venturebeat-survey-finds)
- Maeil Business Newspaper, ["AI technology is ahead but there are no data centers": the Cerebras CEO's warning](https://www.mk.co.kr/article/12175108)
- Digital Today, [Big-tech M&A zeroes in on unicorn AI startups as the big deals pour in](https://www.digitaltoday.co.kr/news/articleView.html?idxno=706907)
- PR Newswire (DXC), [DXC and LangChain Advance Agentic AI Harnesses for Mission-Critical IT Operations](https://www.prnewswire.com/news-releases/dxc-and-langchain-advance-agentic-ai-harnesses-for-mission-critical-it-operations-302906323.html)
- CIO Dive, [IT execs brace for AI agent security incidents](https://www.ciodive.com/news/it-execs-brace-ai-agent-security-incidents/832903/)
- SiliconANGLE, [Trellix Wise for Private Cloud runs AI security operations inside customer environments](https://siliconangle.com/2026/10/13/trellix-wise-for-private-cloud-runs-ai-security-operations-inside-customer-environments/)
- Byline Network, [From research and consultation to review: AI enters securities-firm work](https://byline.network/?p=9004111222620538)
- Consumer Times, [National Pension Service: AI cuts monetary-policy and earnings analysis to 10 minutes](https://www.cstimes.com/news/articleView.html?idxno=723821)
