---
title: "The Day the Pocket Becomes the Data Center"
excerpt: "The blueprint for a 100-billion-parameter phone by 2028, the all-night arithmetic of a Mac running 3.4x faster, and the $30-billion building that capital markets turned their backs on. This week, as the destination of inference changes, the questions companies need to ask change with it."
seo_title: "The Day the Pocket Becomes the Data Center: the 100B phone, the 3.4x Mac, and the rejected $30 billion valuation | ThakiCloud"
seo_description: "Qualcomm's forecast for a 100-billion-parameter phone by 2028, llama.cpp's 3.4x acceleration on M3 Ultra, Firmus's IPO withdrawal, and Nvidia's $25 billion acqui-hire. On the morning that inference moves from the building to the pocket, routing and governance become the company's questions."
date: 2026-10-11
last_modified_at: 2026-10-11
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/pocket-becomes-data-center/"
tags:
  - on-device-ai
  - edge-inference
  - inference-cost
  - qualcomm
  - llama-cpp
  - datacenter-economics
  - agent-governance
categories:
  - llmops
---

The direction in which intelligence moves is changing. Inference that had been gathering only inside the data center descends this week onto the pocket and the desk.

A 3.4x speedup on a Mac, the blueprint for a 100-billion-parameter model in a phone by 2028, a $30-billion building that capital markets turned their backs on, a $25-billion staffing deal Nvidia is negotiating, and 92 sandbox workers that stayed up through the night. Every number in this week's digest points in the same direction.

Here is a map for how to read this week's digest. Two hardware signals, one reversal of capital, one report from the night shift, and one warning from a CEO. The hardware signals are the 100B phone blueprint and the 3.4x Mac. The reversal of capital is Firmus's withdrawal of its listing and Reflection's acqui-hire. The night shift report is the 92 sandbox workers. The warning is Nadella's phrasing of insider threat.

If you have actually run agents, you can see why this week's news matters. The place where models run is starting to change. When the place changes, the cost structure changes, and when the cost structure changes, the number of agents you can run in parallel overnight changes.

The one question a reader of this week's news needs is how to decide where a model runs. Size rankings are the story after that.

## Two signals of the descent

Qualcomm announced that its AI partners have started building their own portable hardware. That is Qualcomm's phrasing for a changing smartphone market. The goal is a device that runs a 100-billion (100B) parameter model on the phone by 2028. This is a forecast that AI companies are beginning to put their hands directly into device manufacturing, and it should be read as a single source from Qualcomm. Both the 2028 and 100B figures are forecasts.

This forecast matters because it suggests the surface for AI serving is beginning to widen beyond the cloud. If 100B runs on a phone, the places running the same model become two: the data center and the phone. The moment serving splits across two surfaces, the character of the question changes. It shifts from where to place the model to which workload runs on which surface. That a model riding on a phone is not a place where a company can simply pull the power is also part of the weight this forecast carries for companies.

That said, there is not just one blueprint. This week, the open-source library llama.cpp merged a new GPU optimization and greatly improved token generation efficiency on Apple hardware. The concrete result is that speculative decoding runs 3.4x faster on the M3 Ultra Mac. Speculative decoding is a technique that reduces generation time by having the model guess tokens first and then verify them in one batch. The caveat is also clear. The 3.4x figure is for M3 Ultra and cannot be generalized directly to other Apple chips.

This merge also means the open-source serving stack is being tuned, little by little, to specific chips. The homogeneous serving that ran a model on one kind of data center GPU widens into a heterogeneous surface mixing Macs and phones and data centers. The era of managing serving at the chip level is coming.

The two events are in different places. One is a blueprint for the pocket, one is a benchmark on the desk. What they share is the curve. The cost of running the same model on something other than data center hardware is coming down on a timetable to 2028. One side is still a plan, the other is already merged code. When a plan and code point in the same direction, we call it a trend.

## Capital turned its back on the buildings

The same week, capital markets price the building in the opposite direction. Firmus, the data center operator backed by Nvidia, withdrew this week its ASX (Australian Securities Exchange) listing application that was meant to raise about $5 billion. The direct reason is that global fund managers rejected the proposed valuation, and the figure carried in the news headline is around $30 billion.

Firmus's business is the data center, that is, power. During the period when AI investment sentiment was concentrating on the ability to secure power, the valuation of a company that had that power was not recognized by capital. Power grows scarcer as demand rises, and that is why the company sought to raise funds through a listing, but global fund managers rejected the price. Once the funding window for data centers narrows, the competition to secure compute gets fiercer.

At the same time, Nvidia is negotiating a $25 billion acqui-hire deal with Reflection AI. It is structured to absorb Reflection AI's staff and technology while avoiding full merger review and antitrust regulation. An acqui-hire that takes people and technology instead of a company is a way to place influence on the supply landscape without going through regulatory review. This deal is also still in the negotiation stage and is not confirmed.

The one story the two deals tell is this. The building was rejected at $30 billion, and the people and technology sat down at the $25 billion table. Capital markets did not reject AI. What they rejected was the concrete and the power itself. When the price of the building goes down, the relative price of the algorithms and the ability to make them goes up.

This structure also affects the supply landscape. Nvidia, the largest compute supplier, absorbing an AI company itself is a window into how GPU supply and price will move going forward. The more supply pools into one place, the more the question of under what conditions to secure compute becomes a decision at the same grade as model choice.

The scarcity of the next few years is set by the execution location. The question is where you can run a model at a low price. The logic of the descent appears again here. There is another layer on which to read the 3.4x. It can be read as a technical answer to capital markets' question of why your building cannot be worth $30 billion.

## 92 at night, 5 in the day

Let's look at the workload that the descent must carry. According to Rohan Arun's report, five agents based on Fable 5.1 submitted five improved bounds on OpenAI's integer multiplication problem over a single night. The agents mobilized 92 sandbox workers. This report is also a single source, and the detailed figures showing the size of the bound improvements were not revealed.

The integer multiplication bound problem is the task of continually lowering the bound that determines how fast multiplication can be computed. Five improved versions of that bound came out of the overnight submission of five agents. The human role now is review. At night the agent works with 92 hands, and in the morning a person chooses which of the bounds to trust.

The shape of this workload is the night shift. It is a structure where 92 isolated execution environments burn tokens in parallel all night, and it is also evidence that the parallelization unit of agent work can grow this large.

Whether the night shift becomes an economy is decided by one variable: cost per token. If the structure is one where 92 workers run only in the data center, the night shift is a premium specification. An agent workload with a large spike demands 92 workers during a specific time of day and drops to zero the next day. A fixed data center contract struggles to handle this demand, and a flexible surface absorbs the spike. If speculative decoding runs 3.4x faster on M3 Ultra and 100B comes onto phones by 2028, the 92 workers can be placed on the desk, at the edge, in their own sandboxes. It is the moment when the number of agents that can run in parallel overnight changes.

Of the five submitted bounds, how many will be confirmed valid in the morning? That is another night task that becomes the human reviewer's job. If the way the agent stays up through the night changes, the way the morning review is done must change too.

Seen this way, the descent is not a story about the elegance of the environment. It is the arithmetic of the night shift.

## Questions that multiply on the widened surface

When the model moves, the surface of governance multiplies. Microsoft CEO Satya Nadella urged companies this week to treat frontier AI as an insider threat. The statement is that a human-controlled emergency brake is essential so that agentic AI models can be stopped mid-task.

Whether that model is safe used to be a question you checked once at the data center door. Now it is a question repeated on every surface. Under what policy does the workload running in 92 sandboxes execute? Who must be the person able to stop an agent on the Mac on the desk? Who reads the logs that the agent inside the 2028 phone will leave?

Unpacked, Nadella's insider threat phrasing means the agent is a person carrying a keycard that can open the doors inside that building. The wider the surface, the more this distinction matters. In the days when you only had to watch one data center, one brake was enough. When the surface multiplies, the brakes must multiply by the surface too. If the model is riding on a phone, the brake must ride on the phone too. If Qualcomm's forecast is right, in 2028 an agent carrying a keycard will perform work from the device in your pocket.

The emergency brake Nadella talks about is a device that stops a workload already running. But there is a question that comes before it: knowing where, right now, which workload is running. The surface multiplies first, and the brake follows after.

## Platform questions of the pocket era

When the destination of inference diversifies, the scarce capability changes too. It is not the model. It is routing. Routing's job is to decide which workload, on which silicon, under which policy, and leaving which logs, will be executed. It becomes the cost problem of the night shift and the governance problem of the surface. The point where the two questions intersect is exactly routing. This question is now raised on every surface.

ThakiCloud's agent-native cloud Paxis is an official product at v1.1 GA. The answer to this question is already in place. Skills, Tools, Policies, and Audit Logs are managed as first-class resources. Isolated sandbox execution is the space that holds the 92 workers. The per-task model selection CostRouter does the arithmetic of the night shift, the policy gate stops workloads before execution, and the audit log records what, who, and why something was stopped. This is the place that answers Nadella's emergency brake question. The autonomy governance L0 through L3 sets what an agent is allowed to do on its own, and the MCP connectors and skill marketplace connect existing tools to the agent.

As Firmus's withdrawal of its listing shows, when the price of the building is shaken, a sovereign on-prem K8s deployment is also an option to keep compute in your own hands.

The 2028 timetable is Qualcomm's. But the 3.4x on M3 Ultra is code merged this week. When 2028 arrives, the parameter count will be written on the spec sheet when you buy a phone, the price per token will be set by the silicon in your pocket, and the governance file will be set by the company. The data center is not disappearing. Only that the answer to where to run intelligence will be written not just on a single electricity bill but also in a single policy file.

## References

This article was written by synthesizing the news below.

- HuggingNews, [AI Agents Submit Five Improved Bounds for OpenAI Integer Multiplication](https://huggingnews.com/ai/update-ai-agents-submit-five-improved-bounds-for-openai-integer-multipli-78c5f66a)
- HuggingNews, [Firmus Abandons $5B Australia IPO Over $30B AI Valuation](https://huggingnews.com/ai/firmus-abandons-5b-australia-ipo-over-30b-ai-valuation-c2771407)
- HuggingNews, [Nvidia Negotiates $25B Reflection AI Deal to Avoid Antitrust](https://huggingnews.com/ai/nvidia-negotiates-25b-reflection-ai-deal-to-avoid-antitrust-d51537de)
- HuggingNews, [Nadella Urges Companies to Treat Frontier AI as Insider Threats](https://huggingnews.com/ai/nadella-urges-companies-to-treat-frontier-ai-as-insider-threats-2451a872)
- HuggingNews, [AI Firms Build Phones for 100B Parameter Models by 2028](https://huggingnews.com/ai/ai-firms-build-phones-for-100b-parameter-models-by-2028-bfaa7cf6)
- HuggingNews, [llama.cpp Speeds Mac Speculative Decoding 3.4x for M3 Ultra](https://huggingnews.com/ai/llamacpp-speeds-mac-speculative-decoding-34x-for-m3-ultra-9e14a5c5)
