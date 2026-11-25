---
title: "Beyond AI-Free Interviews: Building an AI-Native Organization"
excerpt: "AI-era hiring failures are not only a candidate problem. Meta is piloting AI-enabled coding interviews, and OpenAI and Anthropic evaluate independent thinking and AI collaboration separately. If the evaluation methods and work systems, not the candidates, have failed to keep up with the times, the answer is not taking AI away but providing it."
date: 2026-11-26
last_modified_at: 2026-11-26
tags:
  - AInative
  - FutureOfWork
  - Hiring
  - OrganizationDesign
  - EngineeringCulture
  - Paxis
author_profile: true
toc: true
toc_label: Table of Contents
canonical_url: "https://thakicloud.com/tech-blog/en/culture/ai-native-organization-taking-vs-giving/"
categories:
  - culture
---

![Abstract image of AI tools expanding human and organizational capability]({{ '/assets/images/ai-native-organization-taking-vs-giving-hero.webp' | relative_url }})

## In the AI era, who should we work with?

Stories are circulating about hiring in the AI era: candidates who submit work that looks more capable than they really are by leveraging AI.

A polished resume, expert-level take-home assignments, fluent interview answers. Yet reports keep surfacing of people who, once placed in real work, cannot even explain the work product they themselves submitted. As a response, some argue for eliminating remote interviews and banning laptops and AI tools.

We think the problem deserves a slightly different frame. Is the failure one of verifying candidates' capabilities? Is it a failure caused by the use of AI? Or is it a failure of the hiring and work systems that did not keep up with the changes of the era?

This post organizes ThakiCloud's thinking on talent, evaluation criteria, and organizational design in the AI era, from the perspective of the last question.

## 01. Hiring failures reflect a company's evaluation capability too

Misrepresenting one's experience or claiming credit for work you never did is clearly wrong.

But if a company judged capability only by the appearance of a submitted artifact, it should also look at how it evaluates. There is no need to make a strong developer write every line of code by hand from scratch. The more important questions look like this:

- Why was this architecture chosen?
- What alternative technical approaches exist?
- What are the limits of the current implementation?
- How would you respond if requirements changed?
- How would you trace the cause of an incident?
- How would you verify the correctness of AI-generated output?

Marketing roles are no different. What matters is not how polished a report reads, but whether the assumptions behind the data analysis hold up, whether metric definitions are precise, and whether the analysis can be connected to an actual business strategy.

If a company marveled at an AI-produced artifact yet never verified its quality, the interviewers' evaluation capability deserves scrutiny as much as the candidate's.

## 02. Is skill measured with AI removed really the true skill?

For a long time, we have evaluated people around the knowledge and technology they personally hold. But technological progress has continuously changed the range of capability humans can exercise. Every time search engines, open-source software, cloud computing, or automation tools appeared, the way we work changed.

AI sits on the same line of change. The difference is that it touches a far wider range of intellectual work. So the evaluation criteria need to change with the era.

| Traditional evaluation criteria | Criteria for the AI era |
| --- | --- |
| Holding knowledge | Searching for and verifying knowledge |
| Memorizing answers | Defining problems and judging |
| Direct implementation | Design, implementation, verification |
| Writing documents | Interpreting information and deciding |
| Individual output volume | Final outcome and quality |
| Solving problems without tools | Using and controlling tools |

This does not mean foundational knowledge and expertise become unimportant. If anything, evaluating what AI generates requires deeper understanding and judgment in the domain. What we should distinguish is not whether AI was used, but uncritical dependence on AI versus capability extended through AI.

## 03. Global tech companies have already started responding

The companies leading AI technology are already working through this problem through hiring and organizational design. Even the companies that understand AI best do not unconditionally allow or ban it. They separate AI collaboration capability from independent thinking, depending on the purpose of the evaluation.

Meta is piloting AI-enabled coding interviews for software engineers. Since engineers use AI coding tools in real work, the hiring process should evaluate problem solving with AI as well. This is a step beyond catching candidates who use AI secretly: evaluating how they use it.

OpenAI's official interview guide says it values how candidates approach a problem, their decision-making process, and their collaboration and communication skills. Depending on the round, AI is allowed, and it is restricted when the goal is to check independent problem solving. The scope of tool use is set to match the purpose of the evaluation.

Anthropic encourages candidates to use AI to communicate their experience effectively and to prepare for interviews, while limiting cases where AI does the candidate's thinking during evaluations that do not allow it. Using AI and falsely packaging one's experience are entirely different problems.

In April 2025, Shopify CEO Tobias Lütke presented effective AI usage as a baseline expectation for all employees. Before requesting more headcount, teams should first check whether AI can help reach the goal. The company provides AI tools at the organizational level and encourages employees to share their successes and failures. The notable part is that Shopify did not stop at demanding, it built the environment together.

Microsoft CEO Satya Nadella has described in official messages how AI agents are changing the way software is developed and the way companies run business processes. This change does not stop at adding one chatbot to existing work. It is redesigning organizations and systems to match the new way humans and AI collaborate.

These companies do not all take the same approach. But a common direction stands out: they design hiring and work environments assuming AI is here to stay.

## 04. AI can extend individual capability into organizational capability

A study published by Erik Brynjolfsson and colleagues from the Stanford Digital Economy Lab found that generative AI improved customer support agents' productivity by 14% on average. For novice and less experienced agents, the productivity gain reached 34%. The research points to the possibility that AI becomes a medium through which experienced employees' know-how is transferred to others.

That carries an important implication for companies. Traditional companies have relied heavily on the experience and knowledge of a small group of key people. When they left or moved on, the organization's capability was lost with them. Combined with organizational knowledge management, AI can evolve that experience into a form the whole organization can use.

At the same time, we cannot assume AI raises productivity across the board. A 2025 METR study of experienced developers reported that task time actually increased by 19% when using AI tools. Ethan Mollick distinguishes human-AI collaboration modes as Centaur (dividing roles) and Cyborg (tight collaboration across the whole process), emphasizing that the judgment to separate the work AI does well from the work it does not is what matters.

What matters is not the fact of adopting AI, but measuring real outcomes such as quality, cost, time, and error rates. The purpose of AI transformation is to raise organizational capability, not to increase AI usage volume.

## 05. The environment in which AI can be used well is the company's responsibility

Telling employees to "use AI well on your own" is not a sufficient AI transformation strategy. An environment where employees each use AI services with personal accounts, paste company data directly into prompts, and use generated output without verification creates new risks.

Companies need to build a shared foundation on which AI can be used safely and effectively. We see six core elements of an AI-Native Organization.

<div class="mermaid">
flowchart TB
    A["AI-Native Organization"] --> B["AI Infrastructure<br/>Models and compute<br/>matched to the work"]
    A --> C["Enterprise Knowledge<br/>Connecting organizational<br/>knowledge and context to AI"]
    A --> D["Agentic Workflow<br/>Repetitive, structured work<br/>runs on agents and automation"]
    A --> E["Verification and Governance<br/>Testing, approval, and<br/>tracking systems"]
    A --> F["Security and Privacy<br/>Confidentiality, personal data,<br/>and access control"]
    A --> G["Continuous Learning<br/>Successes and failures become<br/>learning for the whole team"]
</div>

If an employee sends an AI-drafted email without review, that is the individual's responsibility. But building the workflow that catches such errors before they reach an external customer is also the organization's responsibility. Competitive advantage in the AI era is created when individual capability and organizational systems develop together.

## 06. Managers have to change in the AI era too

When we talk about talent in the AI era, the people most often overlooked are managers and executives. If we apply the same evaluation criteria used for old work styles to employees who use AI, the new productivity cannot show up inside the organization.

Managers also need to judge the quality of AI-generated output, redesign work, and assign roles between people and AI effectively. The manager's role should shift from assigning tasks to defining problems, from managing workload to managing outcomes and quality, from supervising repetitive work to designing work systems, and from headcount-centered resource allocation to managing people and AI as integrated resources.

Demanding AI capability from employees while managers and executives keep the old work style is hard to call a sustainable AI transformation. AI transformation is not the project of one technical department. It is a management issue.

## 07. The talent profile we are aiming for

The person ThakiCloud is looking for is not simply someone who handles AI well. It is someone who has, and can keep developing, the following capabilities:

- **Problem Definition:** defines problems worth solving
- **Domain Expertise:** understands their own domain and keeps learning
- **AI Collaboration:** uses AI and a variety of tools effectively
- **Critical Thinking:** verifies AI output instead of trusting it blindly
- **Ownership:** takes responsibility for quality and decisions
- **Knowledge Sharing:** evolves their experience into team and organizational capability

Not everyone has all of these from the start. A company's role should therefore extend beyond selecting already-outstanding people to building an environment where people can keep growing.

We aim to evaluate AI collaboration capability and independent thinking together. First, check the candidate's real experience and foundational expertise. Then evaluate their ability to solve real problems using AI and other work tools. Next, check whether they can verify what was produced, respond to the unexpected, and explain their own decisions. Finally, evaluate whether the person expresses their knowledge and experience honestly and can take responsibility for the outcome.

Banning AI alone cannot evaluate these capabilities well. Nor is allowing AI alone enough. We must define clearly which capabilities to evaluate and design the hiring process to fit them.

## 08. The organization we want to build

ThakiCloud is building the technical foundation that lets companies use AI, from AI infrastructure to AI platforms to AI agents. The six elements of the AI-Native Organization discussed in this post connect directly to the direction of the products we build.

Agent orchestration for agentic workflows is where Paxis operates. Paxis treats skills and tools, policies, and audit logs as first-class resources, and every AI action passes through policy gates and audit logs. The verification, governance, security, and privacy elements are implemented on top of those policy gates, access controls, and audit trails. The AI infrastructure element is carried by inference infrastructure like Metis, which serves models across diverse customer environments.

We do not build technology only to replace human work with machines. We build it so that people and organizations can tackle problems that were hard to solve before and exercise a higher level of capability.

A good organization does not rely only on a few outstanding people. It is one that continuously develops its people and accumulates individual knowledge and experience into the competitive advantage of the whole organization. AI can be an important technical foundation for building that kind of organization.

We do not want to stay at the simple claim that we want people who use AI well rather than people who do not. We want to build an environment where people grow further through AI, tackle harder problems, and can take responsibility for the results.

An organization that checks how much further people can grow by providing AI, rather than taking it away to test their abilities. That is the AI-Native Organization we are aiming for.

## References

1. OpenAI, Interview Guide. [https://openai.com/interview-guide/](https://openai.com/interview-guide/)
2. Anthropic, Guidance on Candidates' AI Usage, July 2025. [https://www.anthropic.com/candidate-ai-guidance](https://www.anthropic.com/candidate-ai-guidance)
3. Tobias Lütke, Reflexive AI Usage Is Now a Baseline Expectation at Shopify, April 2025. [https://x.com/tobi/status/1909251946235437514](https://x.com/tobi/status/1909251946235437514)
4. Satya Nadella, Introducing CoreAI: Platform and Tools, January 2025. [https://blogs.microsoft.com/blog/2025/01/13/introducing-core-ai-platform-and-tools/](https://blogs.microsoft.com/blog/2025/01/13/introducing-core-ai-platform-and-tools/)
5. Meta, Q1 2025 Earnings Call. Remarks by CFO Susan Wojcicki on the pilot of AI-enabled coding interviews.
6. Brynjolfsson, E., Li, D., & Raymond, L. R. Generative AI at Work. NBER Working Paper 31161. [https://www.nber.org/papers/w31161](https://www.nber.org/papers/w31161)
7. Becker, J., Rush, N., Barnes, B., & Rein, D. Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity. METR, July 2025. [https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
