---
title: "The Day a Company Wrote Its AI Agents into the Personnel Roster"
excerpt: "KB Insurance gives its AI agents employee IDs and is even reviewing a grading system for them. Hancom hires agents and builds teams around them. Today's news is about the most advanced new hires being onboarded with the oldest institution in the company. Behind the personnel roster hide audit, permissions, approval gates, and cost."
seo_title: "The Day a Company Wrote AI into the Personnel Roster: Agent Governance"
seo_description: "Once agents started taking on real work, companies reached for employee IDs rather than a new system. Why the personnel system, the oldest institution, explains agent governance, and the lens of the agent-native cloud."
date: 2026-09-15
last_modified_at: 2026-09-15
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - agent-governance
  - ai-workforce
  - enterprise-ai
  - agent-ops
  - data-sovereignty
  - identity-access
categories:
  - agentops
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/ai-agent-employee-number-personnel-ledger/"
---

![An image visualizing the concept of a company writing its AI agents into the personnel roster](/assets/images/ai-agent-employee-number-personnel-ledger-hero.webp)
*A visualization of the article's core concept.*

## Six Employees Who Never Take a Lunch Break

Six new employees have joined KB Insurance. They never take lunch breaks, never file travel expense reports, and never leave messages on holidays. Their work is analyzing the fault ratios in auto accident claims and summarizing customer complaints, a load that exceeds one person's monthly workload. The company has issued these six types of AI agents employee IDs and assigned them duties just like regular employees, managing their access permissions and execution history. As a next step it is even considering a performance-based grading system, and it is building an AI-oriented data management system so the agents can work stably.

My first reaction to this news was not "surprising" but "interesting." The most advanced technology inside the company is being onboarded through the oldest hiring procedure inside the company. The new hires are the most skilled in the organization, but the onboarding form is the same piece of paper HR has used for the past hundred years.

This is not one insurance company's hobby. Samsung Life has launched a consultation training service that combines an insurance-specialized language model with a digital human, in which virtual customers converse freely and receive individual feedback when the consultation ends, and it has entered the official launch phase. Samsung Fire & Marine, DB Insurance, Hanwha Life, Shinhan Life, and NH Nonghyup Life are pushing AI into core work such as policy design, underwriting, and claims. In e-commerce, Cafe24 is considering an operation where an agent gathers and analyzes product reviews and customer inquiries overnight and sends a tidy report to the person in charge in the morning. It is like a diligent full-time employee who never clocks out being assigned to the back office.

The solidest evidence is on the semiconductor shop floor. China's Empyrean Technology has unveiled an electronic design automation platform that connects AI agents to chip design, announcing that it cut circuit placement, routing, and simulation time from 4 weeks to 1, a 75% reduction. Work once considered the exclusive domain of veteran engineers is now at the stage where agents perform it autonomously. The line of "agents doing real work" has already crossed chatbots and reached insurance, commerce, and the chip design floor.

## The Most Advanced New Hire, the Oldest Onboarding

The paradox starts here. The moment an agent does real work, a company has to answer four questions. Who is this, what can it do, what has it done, what must it not do. The four questions of governance.

What is interesting is that companies did not invent a new system for these questions. They reached for something that already exists. The personnel system that companies have been running for a hundred years.

You only need to place the items of the personnel system next to the four questions on the agent side. The employee ID answers "who is this." It is the agent's identity. The position is "what can it do." It is the scope of permissions. The performance review is "what did it do, and how was it." It is audit. Internal audit and the prior approval system are "what must it not do." They are policy gates.

Hancom's newly announced AI workforce platform, Nomadian, has the same skeleton. It is a platform that hires agents like employees and composes and operates teams, and it is moving to attack the US market with a world-first launch claim. There are two built-in features worth noting. First, a human approval gate before executing irreversible work such as sending email or an electronic signature. Second, blocking access to unapproved tools. Translated into HR language, these are exactly "separate approval for high-risk work" and "access management by position." A software company arrived at the same conclusion. To manage agents, you first need a personnel roster.

## Why Companies Are Moving Toward "AI Colleagues"

It is not just "because we want to save money." In a Goldman Sachs survey, 76 percent of US small businesses use AI, but only 14 percent answered that they use it fully for core work. The barriers were difficulty in choosing tools at 48 percent and a shortage of technical talent at 49 percent. The share of solo-founded startups among new US startups jumped from 23.7 percent in 2019 to 36.3 percent in the first half of 2025.

These can be read in sequence. Organizations that need AI are small, and organizations that can build it are few. The technical talent needed to build agents is rarer than the companies that want to use them. In this gap, "hirable agents" are not an option but a substitute. Hancom named 30.4 million employeeless US businesses as its first market, aiming right at this gap.

This is where the logic of the employee ID becomes clearer. A company does not merely use what it hires. It manages it. The moment a company begins to regard an agent as a colleague, governance is no longer an option but a precondition of onboarding.

## An Employee ID Is an Identity, Not a Name

It is worth considering why the employee ID appears first. In HR, the employee ID is how the system knows a person's very existence in place of their name. If a name is for calling someone, the employee ID is for the system to identify them. Giving an agent an employee ID is, in the end, a declaration that registers that agent as an entity the system can identify.

KB Insurance's statement that it will manage duties, permissions, and execution history along with the employee IDs of its six agent types means this registration extends beyond a single name to the whole of identity management. Recording who, in which position, with which permissions, did what work and leaving a record is the same structure as personnel management for people. The only difference: a person's personnel records are updated on an annual cycle, while an agent's execution records accumulate by the second. With the same employee ID, it becomes a ledger that must turn much faster and much more finely than the one for a person.

This raises the question of whether the personnel system fits an agent as is. A person's onboarding is a one-time event. You receive the documents, set the position, grant the permissions, and it is over. An agent's onboarding is not an event but a state. Permissions must vary by situation, approval may be needed for every execution, and audit must flow continuously. A system built for people over a hundred years must beat at a different rhythm to handle an entity moving at machine speed.

## 82 Percent: Organizations Without a Roster

What happens when you leave this rhythm problem alone is already known in numbers.

In a survey by the Cloud Security Alliance, 82 percent answered that there are AI agents inside the organization that it does not grasp. Without an employee ID there is no owner. You do not know how many there are, what they do, or who they meet. 65 percent answered that they experienced an AI-agent-related security incident within the past year, and 61 percent of the incident-affected companies experienced data exposure. The greater an agent's permissions, the faster the damage spreads along the scope of those permissions.

The core of this gap is that agents are adopted quickly and rosters are made slowly. When the speed of using first and organizing later outruns the speed of building governance, 82 percent is the scale that measures that gap.

Regulators are writing in the same HR language. The AI Security Guidelines v2.0 that the Korea Internet & Security Agency is producing requires limits on permissions and access scope, records of decisions and actions, and separate approval for high-risk actions. The Cybersecurity Basic Guidelines that the Ministry of Science and ICT has proposed for public comment make it mandatory to draw up a separate security plan when building and operating an AI system, and newly add AI-using projects to the security review subjects. Identity, permissions, audit, approval. Regulators do not invent new words either.

The same story is proven on the consumer device side. Apple officially launched its next-generation assistant Siri AI together with its 2027 software. It understands personal context, reads the screen, and executes actions across apps. The structure combines on-device processing with Private Cloud Compute, which does not store user information during computation. It will support Korean in October. In other words, an agent that understands context, invokes tools, and executes actions has been built in as a standard of the mainstream operating system. If this level is a baseline even for consumer devices, the standard companies must meet can only be higher.

## A Price Is Being Put on Agent Work

If the roster handles identity, permissions, and audit, one more item remains. Payroll.

China's Empyrean has announced that, while using agents in chip design, it will switch from multi-year fixed software licenses to metered billing based on token consumption. It is a structure where you pay in tokens for the work the agent did. Cafe24 runs this through a router that lets you choose from more than 220 AI models via a single API and centrally manages request volume, token usage, and cost per model. Even Apple has set a daily cap on the server-based model usage of Siri AI and said that overages will be offered for a fee going forward.

The three companies are in different industries but writing the same sentence. Agent work is now accounted for in tokens of execution rather than hours of labor. That means a payroll column has appeared in the roster. If a person's salary is determined by rank and seniority, an agent's pay is determined by the model chosen per task and the tokens that execution costs. All the way to the last cell of the roster, HR is moving over to the agent side.

## The Personnel Roster That Became a System

Today's news compressed to one line: once agents started doing real work, companies reached for the oldest ledger in the company, the personnel roster.

This is not a stopgap. The employee ID is a symptom, not an emergency measure. The demands that still have no words of their own for identity, permissions, audit, approval gates, and cost are surfacing in the form of the personnel system. But the personnel roster is a ledger of people, so it is hard to manage agents at machine scale one by one on paper and spreadsheets.

The agent-native cloud provided by the full product Paxis is exactly this personnel roster in system form. In Paxis, skills, tools, policies, and audit logs are first-class resources rather than add-on features. That means what an agent can do, what it can touch, what it must not do, and what it has done are all managed in a structured way. Autonomy is governed step by step from L0 to L3, and every execution passes through a policy gate and remains in the audit log. Execution happens inside an isolated sandbox, and a CostRouter that picks the model per task handles the cost of agent work. A sovereign or on-premises K8s deployment answers the requirement that data not leave the country.

Translated back into the language of the news: what KB Insurance gave its agents was an employee ID and the qualification to receive a grade. What Nomadian built in was approval and access blocking. Paxis is infrastructure where that employee ID and position, permissions, performance, internal audit, and payroll are all first-class resources. The day the most advanced new hire finally receives the most systematic onboarding.

## One Line to Remember

The question when a new entity enters a company is not how smart it is, but whether there is a roster. The employee ID was the start of that roster. The day the roster becomes a system, agent adoption becomes real operations.

## References

This article was written by synthesizing the news below.

- Digital Daily, ["Finally Keeping Its Promise"...Apple Officially Launches "Siri AI" Combined with Next-Generation Intelligence](https://www.ddaily.co.kr/page/view/2026091507492548385)
- Seoul Economic, [Hancom Launches World-First AI Workforce Platform "Nomadian"...Targets the US Market](https://www.sedaily.com/article/20090825?ref=naver)
- News1, ["AI Resolves Sellers' Repetitive Back-Office Work"...E-Commerce Races to Adopt Agents](https://www.news1.kr/industry/sb-founded/6290182)
- Global Economic, ["Chip Design Period Cut to a Quarter"...China's "AI Agent EDA" Offensives Against US Synopsys Monopoly](https://www.g-enews.com/view.php?ud=2026091417570599240c8c1c064d_1)
- News1, [AI That Practices Consultation and Reviews Claims...Digs Into Insurance Companies' Core Work](https://www.news1.kr/finance/general-finance/6287993)
- Digital Today, [MSIT Overhauls the "Cybersecurity System"...Expands to AI, Cloud, and Space](https://www.digitaltoday.co.kr/news/articleView.html?idxno=700351)
- Seoul Economic, [AI That Hacks vs AI That Blocks...Next-Generation Security's "Sword and Shield" Competition](https://www.sedaily.com/article/20090823?ref=naver)
