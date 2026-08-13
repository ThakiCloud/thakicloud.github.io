---
title: "The Day a Firefighting Robot Got Authority to Close a Fire Door, the Approval Chain Still Did Not Exist"
excerpt: "Between August 12 and 13, agents received execution authority in inboxes, calendars, and at fire scenes, all at once. During the same two days, the National Assembly pointed out that no one has yet decided who is responsible for that authority. Reading a situation where authority arrived first, and the paperwork to delegate it has not."
seo_title: "Agent Execution Authority Has Outrun Governance | AI News Analysis, August 2026"
seo_description: "Reading Hancom's Agentic OS deployed on firefighting robots, Grok's expanded work connectors, Pixel 11's booking delegation, Naver Cloud's EASY, and a National Assembly critique of physical-AI governance gaps as a single axis, and laying out the execution layer companies need to prepare now."
date: 2026-08-13
last_modified_at: 2026-08-13
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - agentops
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/agent-authority-arrived-before-the-approval-line/
---

The decision to close a single fire door at a fire scene is heavier than it looks. Closing the door traps the fire and smoke inside, but there might still be someone in there. Until now, this call has belonged to the commander on scene, and when the call went wrong, responsibility had a clear address.

Hancom's subsidiary Hancom Life Care signed a five-year exclusive domestic deal with the French robotics company Shark Robotics, and by the end of December will integrate Hancom's Agentic OS into the large firefighting-rescue robot Colossus and the fire-door-blocking robot Rhino Protect, BizTribune reported. An agentic OS is not a way of running individual AI tools separately, it is an operating system that controls multiple agents within a single system. It analyzes the information the robots collect in real time and relays hazard zones and entry routes to the command structure. This is the first case in which orchestration that used to run purely inside software has come down to the control layer of physical equipment.

The figures Hancom attached to this deal are worth noting too. It said it plans to expand into industrial robots for logistics, construction, and defense, and estimated the addressable market for sovereign agentic OS in 2030 at between 10 trillion and 14 trillion won. It picked Europe as its first global strategic market. Whether these figures hold up is not something we can judge now, but at minimum, one company is treating agent orchestration not as an extension of document-editing software, but as its own independent market.

![Conceptual image representing the day a firefighting robot got authority to close a fire door, and the approval chain still did not exist](/assets/images/agent-authority-arrived-before-the-approval-line-hero.webp)
*A conceptual illustration of the article's core idea.*

## In Two Days, Authority Expanded in Four Different Places

Lay the same two days of news side by side, and they converge on one direction.

xAI expanded Grok into a work agent connected directly to Gmail, Google Calendar, Outlook, OneDrive, Teams, SharePoint, and Salesforce. According to TokenPost, it performs email search, drafting, and sending, as well as creating and deleting calendar events, all through connectors. That is not read access, it is write access.

Looking at the numbers alone, Grok's expansion should be read cautiously. In the generative-AI chatbot market, ChatGPT holds 59.5% and Microsoft Copilot 14.3%, while Grok's share is still under 1%. There is a clear gap between how fast the feature set is growing and how fast actual adoption is. Still, this is a signal because even a low-share latecomer chose to compete not on conversation quality, but on access to work systems.

At the Made by Google event on August 12, Google unveiled the Pixel 11 with Gemini Intelligence front and center. According to IT Chosun, the feature list includes placing grocery orders, booking rides, and calling restaurants to make reservations on the user's behalf. The smartphone has gone from a tool that opens apps to an agent that places calls to the outside world on the user's behalf.

Naver Cloud unveiled EASY, a no-code agent builder, at a public-sector AX strategy seminar on August 13. According to Digital Times, entering a task in natural language immediately produces a working agent, and starting in September, deployed engineers will begin identifying tasks agency by agency. Naver Works has already been adopted as the collaboration tool for projects at the Ministry of the Interior and Safety and the Ministry of Science and ICT, with a rollout target of 700,000 public servants.

Inboxes and calendars, a consumer's phone call, the public administrative network, and a fire scene. Four seemingly unrelated places saw the same change happen within two days. Agents moved from being something that says things to being something that does things.

## Authority Arrived, But There Is No Job Description

When a new employee joins a company, they do not just get authority. There is a contract, a job description, an approval chain, designated system access, and a pre-written answer to who is responsible when something goes wrong. This pile of paperwork feels tedious, but it is actually what makes delegation possible.

Agents do not have this paperwork yet.

At a National Assembly Trade, Industry, Energy, SMEs, and Startups Committee hearing on August 12, Assemblyman Kim Jong-min pointed out that physical-AI governance is underdeveloped. According to Chungcheong News, related work is split between the Ministry of Science and ICT and the Ministry of Trade, Industry and Energy, with no integrated policy covering manufacturing, mobility, robotics, and humanoids. In the government's large-scale investment plan, the 800-trillion-won figure for semiconductors and the 550-trillion-won figure for AI data centers are specified, but the official investment amount and project scope for physical AI remain unclear. Kim said he has raised this same issue for a year, and the vice minister of trade, industry and energy responded that he agrees and will push to rebuild governance.

The cost of this gap is not abstract. When jurisdiction is split, budget allocation and project announcement timing wobble, and companies get no signal to plan investments around. Both the companies building the robots and the companies selling the infrastructure those robots will run on are left preparing without knowing what will be ordered, or when. The fact that the National Assembly has repeated the same criticism for over a year is itself evidence that coordination cost is high.

Reordering these two facts makes the meaning sharper. The contract to embed an agent in a robot has a fixed date, the end of December. Inside the government, who has jurisdiction over that robot has been undecided for a year. This is not the usual complaint that regulation is slow. It is an observation that the speed of designing execution authority and the speed of designing responsibility are pulling apart.

## The Side That Already Drew the Approval Chain Has an Answer

What is interesting is that products have started filling the space regulation left empty.

The Pixel 11 lets the user step in or cancel while the agent is placing a reservation call, and leaves a text transcript once the call ends. That is not a convenience feature, it is a minimal implementation of approval and audit. Grok was designed so that a team administrator controls connector registration, access scope, and removal. It is a structure that hands permission scope back to the administrator.

In other words, even consumer products have concluded they cannot sell execution authority without attaching an intervention point and a record. In an enterprise environment, the bar rises several times over. There needs to be a record of which agent called which tool, over what data scope, under whose approval. Finance and the public sector go further, requiring proof that data never left the boundary.

Evaluation criteria have shifted the same way. According to Digital Daily, the second round of the Ministry of Science and ICT's sovereign AI foundation-model evaluation has moved its center of gravity from benchmark scores to agent competence at actual work and the ability to sustain multi-step tasks. The four models submitted by LG AI Research, SK Telecom, Upstage, and Motif Technologies now compete not on parameter count, but on the ability to carry a task through multiple steps to completion. A line from Jin Eun-sook, ICT President at Hyundai Motor Group, at the company's AX results presentation, carries the same message: the goal is not to be the company that uses AI the most, but the company that uses it best. It is a declaration that looks at outcomes, not usage volume.

Hyundai Motor Group has already turned that judgment into infrastructure investment. According to Dae Han Kyung Jae, it is building a 500-megawatt-class AI data center in Saemangeum, targeting 2030 for operation, and has secured supply through a GPU partnership with Nvidia for 50,000 units. It has also built its own generative-AI platform, H-Chat Pro, tailored to its internal security standards. It is a two-track approach: invest directly where product competitiveness is at stake, as with autonomous driving, and use outside solutions for operational efficiency. What matters here is not the size of the investment, but the baseline. A major domestic conglomerate has already started treating running internal agents within security requirements as a given.

The conditions on the sovereign-model side are demanding too. The government will support GPUs, data, and personnel worth 530 billion won through 2027, but only three teams will pass the second round to move to the next stage. The public evaluation includes results from 200 ordinary citizens who actually used the models. That means the judgment reflects the feel of people who actually put the models to work, not just lab metrics.

## So What Companies Need to Prepare Now Is Not a Model

Three threads point to the same place. Agents already execute. The system meant to govern that execution has not arrived yet. And evaluation looks at the results of execution. For now, closing the gap between these will fall to each company's own platform choices, not to institutions.

The public-sector timeline is already set too. EASY targets a formal launch in the first half of 2027, and before that, agency-by-agency task discovery starts in September. While discussion of rebuilding governance proceeds in the National Assembly, tools for building agents are being deployed on the ground first. This is not about which side is right or wrong, it is better to accept that the order has already been set this way, and prepare accordingly.

This is exactly why ThakiCloud designed Paxis as an Agent-Native Cloud and made skills, tools, policies, and audit logs first-class resources. The tools an agent can use and the scope it can access are declared as policy, and autonomy is split into tiers from L0 to L3, so the organization itself decides how far to let execution run automatically and where a human needs to approve. Every execution happens in an isolated sandbox, and the history of calls and approvals is kept as an audit log. Scale up the intervention button we just saw on Pixel and the administrator controls on Grok to enterprise size, and you get exactly this structure.

From an operations standpoint, the hard part is not declaring the policy, it is confirming that the declaration is actually enforced at execution time. An approval rule that only exists on paper will not intervene once even across a hundred agent calls. Permission scope and approval steps need to sit as gates on the actual execution path, and whether they were passed needs to remain as a record you can look up afterward. What meetings and approval documents used to do for people, the platform now has to do for agents.

Where things run is part of the same problem. Organizations that cannot let data leave, public sector, finance, defense, cannot simply accept external SaaS connectors as they are. Paxis being built to run on sovereign environments and on-premises Kubernetes is not a workaround for that constraint, it is a decision made from the start as a premise. Add CostRouter, which picks a model per task, and you can keep execution cost in check by handling simple classification cheaply and reserving large models only for multi-step judgment.

Rebuilding governance will finish eventually. But before it does, firefighting robots are already heading into the field, agents are already going into the work tools of 700,000 public servants, and someone's calendar is already being edited by something other than a person. Not many organizations can afford to wait for institutions to draw the approval chain. The question to ask right now is not which model to use, it is how far an agent in our company can act on its own, and where that record is kept. Only organizations that have an answer to this question will be able to put agents to real work next quarter.

## References

This article was written by synthesizing the following news sources.

- Financial Post Korea, [Chey Tae-won and Jensen Huang to Reveal "$500 Billion Investment Details" at Indiana Fab Groundbreaking in Two Weeks](https://www.financialpost.co.kr/news/articleView.html?idxno=270238)
- Newspim, [Mining Semiconductor Pearls From Japan: TOWA Part 2, HBM Back-End Core, Dominating Over Half of Molding Equipment](https://www.newspim.com/news/view/20260812001098)
- Digital Today, [AI Data Center-Driven Power Semiconductor Market Enters New Phase as 8-Inch SiC Transition Accelerates](https://www.digitaltoday.co.kr/news/articleView.html?idxno=692380)
- Cheonji Ilbo, [SK Hyper CEO Seok-geun Jeong: "The Essence of the AI Race Is a War Over Infrastructure"](https://www.newscj.com/news/articleView.html?idxno=3424654)
- Edaily, [AI Infrastructure Market Grows Larger, A&M: "Neoscaler Emerges as a New Competitive Axis"](https://www.edaily.co.kr/news/newspath.asp?newsid=07091366645546664)
- Wikitree, [IBM Builds Inference Cluster With Together AI Using 2,000 Blackwells](https://www.wikitree.co.kr/articles/1152118)
- Digital Today, [Tech Inside: Why Is Nvidia Trying to Develop Large AI Models Directly?](https://www.digitaltoday.co.kr/news/articleView.html?idxno=692663)
- IT Chosun, [Is the App-Opening Smartphone Over? Google Pixel 11 Bets on an "AI Phone That Acts on Its Own"](https://it.chosun.com/news/articleView.html?idxno=2023092168037)
- Digital Daily, [Sovereign Foundation Model Round Two Part 1: Four Models With Improved Inference and Agent Performance Face the "Real-World Competitiveness" Test](https://www.ddaily.co.kr/page/view/2026081217071457815)
- Digital Times, [Naver Cloud Adds AI Search and Agent Features to Public-Sector Naver Works](https://www.dt.co.kr/article/12077999?ref=naver)
- BizTribune, [Hancom Embeds Agentic OS Into "Firefighting Robots," Formally Enters the Physical AI Market](http://www.biztribune.co.kr/news/articleView.html?idxno=357355)
- TokenPost, [Grok Expands Into a Work AI That Handles Mail and Calendars](https://www.tokenpost.kr/news/cryptocurrency/389584)
- Dae Han Kyung Jae, [Hyundai Motor Group AX Results: ICT President Jin Eun-sook Says "Not the Company That Uses AI the Most, but the Company That Uses It Well"](https://www.dnews.co.kr/uhtml/view.jsp?idxno=202608121203170810747)
- TV Chosun, [Beyond Documents, Into the Production Floor: Korean Manufacturing's AI Transformation Race Heats Up](https://news.tvchosun.com/site/data/html_dir/2026/08/12/2026081290250.html)
- KBC Gwangju Broadcasting, [Exclusive: Shinsegae's 10-Trillion-Won "AI Factory" Considers the Honam Region as a Leading Candidate Site](https://www.ikbc.co.kr/article/view/kbc202608120056)
- Chungcheong News, [Assemblyman Kim Jong-min: "Physical AI Governance Is Unclear," Ministry of Trade, Industry and Energy: "Will Push to Rebuild It"](http://www.ccnnews.co.kr/news/articleView.html?idxno=413405)
- Digital Times, [Google Absorbs Part of DeepMind Into Headquarters, Strengthening AI Competitiveness](https://www.dt.co.kr/article/12078033?ref=naver)
- Wikitree, [Lovable Raises $400 Million in Series C, Doubling Its Valuation to $13.3 Billion](https://www.wikitree.co.kr/articles/1152119)
