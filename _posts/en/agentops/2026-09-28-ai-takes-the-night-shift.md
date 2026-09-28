---
title: "The AI That Took the Night Shift"
excerpt: "The National Intelligence Service's unmanned AI cyber defense team, Project Phalanx, has been put into live action, and Jensen Huang has declared cybersecurity the next growth axis for AI. In the week AI started taking the night shift of defense operations, what companies should prepare first is the rules."
seo_title: "The AI That Took the Night Shift: NSIS Phalanx and the Next Growth Axis for Cybersecurity | ThakiCloud"
seo_description: "NSIS's AI cyber defense team Phalanx was put into live action at APEX 2026, and 24-hour unmanned AI defense operations have begun. In the same week, Jensen Huang named cybersecurity the next growth axis for AI, and AI and machines joined the list of entities that access permission management must cover. We look at the governance devices needed to hand autonomous response workflows to the field, through a Paxis lens."
date: 2026-09-28
last_modified_at: 2026-09-28
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/ai-takes-the-night-shift/
tags:
  - ai-cyber-defense
  - autonomous-agents
  - machine-identity
  - cyber-governance
  - agent-ops
  - security-operations
  - sovereign-cloud
categories:
  - agentops
---

From September 16 to 18, attention turned to a stage at COEX. On the floor of APEX 2026, eight foreign defense teams from NATO member states and the Indo-Pacific region had gathered. Standing next to these teams before the same attack scenario was one more team, operated by no people at all. In that team, several AI programs divided the roles, and it carried out the entire process on its own, from threat detection to attack path analysis, system recovery, and writing the response report. Coverage described this scene as the world's first live deployment of an AI cyber defense team, and the team's name was Project Phalanx.

The description that this marks the start of 24-hour unmanned AI defense operations was attached to the event. It is the job of guarding the front line without rotation and without rest. The heaviest job for a human is the one AI started taking on this week. In the same week, from the industry side, there was also a declaration that cybersecurity is the next growth axis for AI. The signal running through this week's news is that both point to the same place. Before you are ready to hand over the night shift, the rules come first.

The phrase night shift is used for a reason. Cyber defense is a problem of the night. Operations that run only in the daytime cannot keep up with attacks that move overnight. That is why the number 24 hours has served as the benchmark that separates defensive capability. And the fact that it is hard for people to fill that benchmark was already known to everyone in the industry.

![An image picturing the concept of AI taking the night shift](/assets/images/ai-takes-the-night-shift-hero.webp)
*A picture of the article's core concept.*

## A team not on the scoreboard

Phalanx's scoreboard is blank. Because an AI team's response speed differs from a human's, it was excluded from scoring. That is why interpretations split. Talk circulated that it had beaten top-tier human talent, but the article made clear there is no evidence for that reading. Holding that line seems to matter. What was verified this week is the question of whether response without human intervention can run on a live front.

Looking at the exercise's structure, you can see the weight of that question. The eight foreign defense teams come from NATO member states and the Indo-Pacific region. It is an evaluation where the allied teams NSIS normally works alongside faced the same attack scenario on the same field. It was not a separate track. Being excluded from scoring can also be read as meaning it is hard to measure against a human baseline time. If the very premise of response speed starts from humans, this is also a signal that the rule needs to be rewritten. The word to watch here is live. It means the team was run in an actual attack scenario. The fact that the first deployment is live is itself an implication that this technology has been organized as part of the staffing system.

Who built Phalanx also stands out. Centered on the National Intelligence Service's National Cyber Security Center, the Ministry of National Defense, the National Security Technology Research Institute, SteeLion, and the Financial Security Institute took part in development, and Naver Cloud supported the underlying environment. A combination where a security agency, security companies, and a cloud operator sit on one team is rare staffing in the defense field. It also means a multi-agent pipeline, where several AIs divide the roles, has moved inside the national defense structure.

## The four stages of the night shift

According to the coverage, Phalanx carried out the entire process, from threat detection and attack path analysis to system recovery and writing the response report, with several AI programs dividing the roles. Take the four stages in order, and the first thing you see is what a human loses in the night shift.

Detection is a 24-hour problem. Attacks do not stop while people sleep, so if detection is left to humans only, a structural hole remains. Attack path analysis is the stage that has to go beyond what happened and draw where it moved. Recovery is the moment that needs the most judgment. It is the stage that decides how far the system fixes itself and where a human hand is required. Detection and analysis can be undone if wrong, but from recovery onward, hands start touching the system. The point where autonomy is put to the test is right here. The last stage, writing the report, is for the people of the morning. It is the work of leaving what happened all night in a form a human can read, and it is also the prototype of the audit log.

A company can translate these four stages into work it already knows. Detection becomes monitoring in security operations, path analysis becomes forensics, recovery becomes incident response, and the report becomes the incident report. What changed this week is only that an agent took on this sequence itself.

The four stages ran as a division of roles among several agents. That is the form that reached the field this week. In national security, the area with the highest trust, it has been confirmed that an agent's unit of deployment is the workflow.

## The same week, different hands

In the same week, the words of the people selling chips moved. NVIDIA CEO Jensen Huang named cybersecurity the next major growth field for AI. Palo Alto Networks is applying its own AI system, Precision AI, and generative AI to security products, and IBM has brought technology that identifies, verifies, and responds to software vulnerabilities using generative AI into enterprise services. It is as if NVIDIA, the one selling compute, has joined the competitive landscape that had been tied to AI security, pointing at the next growth axis. For the side selling GPUs to say the next is security is a market statement with weight. It is also the start of the expectation that compute, which had been poured into AI development, will flow into defense operations as well.

And there is one more sentence that newly appeared this week. The description is that as AI agents access enterprise systems and data directly, the need to manage access permissions for AI and machines, not only users, has grown. It is the moment something other than a person first entered the subject of access permissions. For a person, you change the password and reclaim the badge. For a machine, this work had to happen at the system level, and it had to be traceable. It must be a structure that grants only the smallest permission, reclaims it immediately when the use disappears, and leaves a record of which data it touched and how much. The grammar of permission management that people used applies to machines too, but the speed and scale are different, so the device must be different as well. Now, cybersecurity is the work of directing an agent with one hand and opening doors to the agent with the other. It includes guarding the door itself.

## Deployment and the rulebook, the same day

NSIS put its defense team into live action and, at the same time, released the rulebook. At CSK 2026, it presented together the plan to link the public cloud information classification into a confidential, sensitive, and public system, red team guidelines for inspecting AI systems from an attacker's perspective, software supply chain security, and a post-quantum cryptography transition plan. Unraveled one by one, all of them read as the spec before handing the night shift to AI. It is as if, while handing over the night shift, it also handed over the rotation chart and the emergency manual.

Linking cloud information classification into a confidential, sensitive, and public system means deciding, before deployment, at what level an agent touches what data. The red team guidelines are the procedure of checking with an attacker's eyes before trusting an agent. Software supply chain security is the work of looking at the software an agent depends on, and the post-quantum cryptography transition is preparation for a future in which data encrypted today could be decrypted tomorrow. Releasing these four on the same day as the live deployment seems to mean it will not send the people first and fill in the rules later. The deployment itself assumes the rules.

A signal in the same direction was confirmed in New York as well. The World Economic Forum SDIM26, held for four days from the 21st of last week, was attended by more than a thousand leaders, including 600 corporate executives and senior representatives from government, international organizations, and civil society. WEF Managing Director Matthew Blake emphasized that AI development is becoming capital-intensive competition through rising demand for compute, energy, infrastructure, and talent, and that a new public and private approach is needed for technology accessibility and guardrails. A survey presented at the same venue also found that 63 percent of companies name the technology and skills gap a major obstacle to transformation. At the same venue, a WEF report came out that efficiency measures can cut data center energy use by 6.5 to 11 percent. The work of putting a defense team on the front line and the work of writing guardrails moved in the same week.

## The night shift that arrives at companies

A company's front line is not the APEX stage. The moment an agent touches production systems and data directly, the same question arrives. Who to leave detection with, how far to let recovery run on its own, where the morning report will be left. That is the question. What a company asks when assigning a night shift to a person is similar. The scope of permissions, the reporting cycle, the criteria for emergency judgment. The difference is that for these questions a human is answered with trust and management, while AI has to be answered with an execution device.

The closest company analogy is security operations. From intrusion detection and incident analysis to blocking measures and response reporting, it is work that runs in the same order as Phalanx's four stages. The reason a company should read this news seriously today is that the experiment of filling this work's human seat with AI is already being run at the national security level.

That is the point where ThakiCloud's Paxis holds Skills, Tools, Policies, and Audit Logs as first-class resources. The governance that divides autonomy from L0 to L3, the policy gate and audit log where execution unlocks only after passing policy, isolated sandbox execution, tools that extend through MCP connectors and a skill market, the execution environment built on sovereign and on-premise K8s (ai-platform), and the CostRouter that picks a model per job to tune cost. These are the devices that have to be ready together for a multi-agent workflow to take on the field's night shift.

The structure of the NSIS exercise can also be read as a preview of company organization. A security agency, security companies, and a cloud operator sitting on one team means the IT, security, and cloud teams inside a company should sit before the same attack scenario. And the fact that Phalanx ran on top of Naver Cloud's underlying environment points the same way. The package that the public and defense sectors will ask for next is likely to be the bundle of sovereign cloud and autonomous security agents. On the other side of the technology and skills gap that WEF confirmed in 63 percent of companies sits this execution device.

## It has to be explainable in the morning

Taking on the night shift requires two things. Enough capability to be handed the shift, and enough rules to run through the night. Put the two side by side, and this week was the week that showed capability. The next week continues as the week that asks about rules. After the defender changes from human to AI, a company's difference no longer comes from a stronger model. It comes from a system that can still be explained in the morning after handing over the night shift. And the organization that accumulates systems that can be explained becomes the organization that can hand the next night shift to a higher autonomy.

## References

This article synthesizes the news below.

- DailyHengwan, ["Stops on its own, with no people ... NSIS deploys the world's first 'AI cyber defense team' in live action"](https://www.dailyt.co.kr/newsView/dlt202609280001)
- The Fair, ["NVIDIA's Jensen Huang: 'Cybersecurity is AI's next growth axis' ... Palo Alto Networks and IBM technology race"](https://www.thefairnews.co.kr/news/articleView.html?idxno=89084)
- AI Newspaper, ["World Economic Forum discusses AI sustainability ... 'Investment in compute, energy, and talent needed'"](https://www.aitimes.kr/news/articleView.html?idxno=42075)
