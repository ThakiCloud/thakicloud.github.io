---
title: "AI Got an Employee ID"
excerpt: "The story of security is changing. It is no longer about who got in, but about what authority was given to whoever is inside. A scenario in which an employee who knows the internal systems moves tens of GB of confidential data with AI, two agent access control patents, and office agents up 14x. If AI is a new employee, what companies need is not a wall but an HR system."
seo_title: "AI Got an Employee ID. It Is a Question of Authority, Not Walls | ThakiCloud"
seo_description: "An insider threat scenario where tens of GB of confidential data moves without any hacking tool, SoftFrick's two agent access control patents, and ChatGPT Work's 14x surge. An analysis of what companies should prepare before agents become insiders."
date: 2026-10-13
last_modified_at: 2026-10-13
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
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/ai-got-an-employee-id/"
---

## The scenario the column drew first

Today's News1 desk column started with a scenario. An employee who knows the internal systems well no longer needs to copy files to an external drive at night. There is no need to build a complex hacking tool. You only have to ask an AI with authority to organize and move the data, and tens of GB of confidential material leaves the company.

The column's core point is simple: "with insider authority alone, AI makes data exfiltration easy." That is a phrase that will feel strange to anyone in the industry who has been designing security for a long time. For years, the premise of the security system has been that the enemy comes from outside, and systems were built on the idea that a solid wall keeps the inside safe. But in this scenario, no wall appears. The person is already inside, the badge is valid, and the behavior happens within the scope of the authority that was granted.

What differs from a human is speed and volume. When an AI starts doing the work of a privileged account in bulk and at high speed, the damage a single credential can cause grows exponentially. That is why the column asked whether security is ready, and the financial sector has already started to tighten the reins on security over concerns about data exfiltration and abuse of authority from expanded AI use.

## It is not that the wall collapsed; it is the moment where authority was enough

The economics of data exfiltration can be split into two phases. First you get authority, then you move the data. In the past, both phases took real effort. The second phase, pulling out a large amount of material and getting it out without a trace, was itself a skilled task. What AI has compressed is the cost of that phase. To say that insider authority alone makes exfiltration easy is the same as saying that the authority itself became the only cost.

So the center of gravity of security shifts by one notch. "How much authority did we give" becomes a more important question than "who got in." And the current authority system has a gap, because it was designed on the premise of a human. It knows how to hire a person, how to invalidate a badge at retirement, even how to temporarily raise authority. But it does not know about a new actor that logs in under your name, handles hundreds of files a day, and never stops.

What the badge system needs to learn new is this: how to issue a badge to something that is not human. The core is least privilege. Just as a person receives only the authority a role needs, each agent and each skill needs its own badge and work scope. A single common ID with "organization-wide access" is the starting point of the scenario the column sketched. And a record must remain for every moment that ID is used. Authority, action, and record are the minimum requirements of a badge system for the agent era.

And the point where that minimum requirement breaks is the incident. Following the column's analysis, the moment a credential is compromised or an agent with excessive authority exists inside the organization, the damage one ID can cause grows exponentially. In the past, the side gaining authority was technically difficult; now, the "behavior" of the side holding authority becomes uncontrollable. The battleground of security has moved from intrusion defense to authority management.

## Patents have been issued. A gateway that blocks agent behavior by policy

Today's news carried a signal that industry is starting to fill this gap directly. According to a Venture Square report, API management and security vendor SoftFrick has obtained two patents. One is a technology for diagnosing privacy vulnerabilities in multimodal AI models. It checks in advance for sensitive information exposure in combined attack scenarios that mix text and images, and it is one of the five AI privacy vulnerability diagnosis patents the company filed last year.

The remaining one is the core of this article. It is a technology where an AI gateway controls prompts and system behavior according to security policy. When an agent calls a model or reaches for an enterprise system, the gateway does not simply pass the request through. It sits in the middle, compares the request against policy, and decides whether to allow it. SoftFrick plans to apply this patented technology in stages to its existing vulnerability diagnosis solution F-Avata and to the LLM and AI gateway it is developing.

The context of the report adds another layer. Attackers are also using AI to discover vulnerabilities and to automate attacks, so a human-centered response cannot keep up in speed and scale. In a phase where AI-based defense and model verification must run in parallel, the AI security market is forming quickly. That is why the two patents SoftFrick obtained are read not just as one company's product roadmap, but as a cross-section of the direction the whole industry is heading. It is a signal that "security for agents" is moving from debate on conference tables into products and standards.

The significance lies in what problem got patented. Not a new encryption algorithm, not a thicker firewall: agent access control. It means the industry is starting to attempt bundling into products and standards the questions of what authority to give an agent, how to control its behavior, and who records it. Microsoft's CEO arguing that "AI requires an emergency brake and must be controlled like insider risk" is in the same context, and the trend of agent access control, least privilege, and auditing rising as core topics at security conferences is in the same direction.

## The agent is already in the office

Meanwhile, the pace at which agents are entering the workplace is a separate matter. According to a Yonhap News report, the enterprise AI agent push by OpenAI and Anthropic has gone full throttle. Anthropic's Claude Cowork and OpenAI's ChatGPT Work are spreading across desktop, web, and mobile, and are taking their place as actors that directly perform the entire workflow. They are not named assistants that answer questions; they are agents that move through files, email, and calendars.

The domestic numbers are even faster. In the same report, OpenAI's ChatGPT Enterprise user count in Korea grew 28x year over year, and ChatGPT Work's weekly active grew 14x in six months. Market size is moving in the same direction. The global enterprise AI market is projected to grow from $38.68 billion this year at 34.3% annually through 2033 (Global Information), and the agent-type AI market alone is projected to grow from $2.42 billion to $1,057 billion by 2035 (Astute).

The form of competition changes with it. The same Yonhap News report also mentions Block's "Buz," which is trying an open agent collaboration environment not dependent on a particular AI model or vendor. It is that the competition is expanding beyond feature battles into data utilization, work execution, and platform dependence. From a corporate standpoint, "which agent do you use" is becoming "under which platform's rules will the agent's authority and record be handled."

Adoption is growing exponentially. Meanwhile, the identity system that grants authority, verifies behavior, and leaves a record is still on the human premise. It is less a matter of whether you are ready than a time gap: how many quarters can you endure the state where the agent is already working but the badge has not been issued yet.

## One public institution's answer: not issuing a badge

A contrasting case also appeared in the same morning's news. According to a report by The Seoul Economic Daily, Incheon Transportation unveiled a maintenance AI that won the top prize at the 2026 Incheon Metropolitan City AI Utilization Idea Contest. It is a chatbot-type solution that shortens maintenance manual search time for electric train failures by up to 90% compared to before.

The interesting part is how it was built. It combines a closed on-device AI cut off from external communications with AES-256 encryption. It did not just decline to let the agent into the office; it gave it no network, no badge, no chance to touch external data. The report also noted that, without external contractors, in-house employees developed it themselves, saving roughly 287 million won in budget.

This is not an isolated case of a single institution. It sits inside the flow of AI transformation spreading across Korea's railway and urban rail maintenance as a whole. Korail received the top policy-object prize with its AI digital twin maintenance platform, and Gwangju Transportation is also discussing AI integration for subway maintenance. As repetitive maintenance work in public fields that relied on specialized personnel starts to be replaced by AI, in-house development competition is also intensifying. As the scope of the "employee who does not clock in" that Incheon Transportation showed expands like this, the identity and audit question this article raises today becomes more urgent.

For a single use case, it is a working answer. If you do not give the machine authority, a network, or a badge, the insider problem does not occur in the first place. But it is not realistic for a company to build a closed station for every work item. "The way to not let it do it" gives way to "if you have to let it do it, with what authority, where, leaving what record will it work" as the more general question.

## What would an HR system for a new employee look like

If you think of the agent as a new employee, what the company needs is not a wall one notch thicker but an HR system for that employee. Four questions are the core. What can this employee do. How far can it reach. Where does it work. And who records what it did, and who takes responsibility.

ThakiCloud's agent-native cloud Paxis is a formal product (v1.1 GA) designed on the premise that these four questions are handled as system functions. In Paxis, Skills, Tools, Policies, and Audit Logs are managed as first-class resources. Autonomy levels L0 through L3 have governance applied step by step, and a policy gate checks authority before execution. All agent behavior is executed within an isolated sandbox and left as an audit log.

The correspondence with this morning's news is also concrete. The "agent behavior control by policy" that SoftFrick bundled with its gateway patent is not a separate device in Paxis but the default behavior embedded in the policy gate and audit log. The execution model without authority that Incheon Transportation demonstrated on a closed network expands as a form with audit records attached on Paxis's sovereign/on-prem K8s (ai-platform) environment. The question of which model to use for which task is handled by a per-task model selection CostRouter. As agents increase, model call costs grow together, and this is a cost governance function that comes onto the same table as this employee's badge management. The MCP connector and the skill marketplace are the parts that connect this employee to external systems.

In one line: in Paxis, issuing a badge is skill registration, designating work scope is policy creation, and looking up behavior records is audit log search. HR procedure becomes system function.

Right now, the 28x and 14x adoption speed is colliding with the human-premise badge system, and the damage scenario the column drew is no longer a hypothesis. The day the agent gets a valid badge, has its work scope set, has its working place isolated, and has its behavior record exist is the day the insider threat starts to become manageable.

## In closing

The column's question "is security ready?" is still valid. But the definition of ready has changed. It is not ready to make the wall thicker, but ready to manage the badge. The company that has finished issuing a badge to the agent and has a record left for each of its behaviors can give the answer first.

## References

This article synthesizes the following news.

- Yonhap News, [[AI Prism] AI handles work now too, ChatGPT and Claude eye collaboration tools](https://www.yna.co.kr/view/AKR20261012160700017?input=1195m)
- The Seoul Economic Daily, ["Maintenance manual search cut 90%," Incheon Transportation takes 1st in AI contest](https://www.sedaily.com/article/20100750?ref=naver)
- Venture Square, [SoftFrick obtains 2 patents for AI sensitive-info leak diagnosis and agent access control](https://www.venturesquare.net/1119206/)
- News1, [[Desk Column] Insider authority left to AI, is security ready?](https://www.news1.kr/it-science/security-hacking/6317531)
