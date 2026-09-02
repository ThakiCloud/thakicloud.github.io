---
title: "The Chip Agents Need Most Is Not the GPU"
excerpt: "In the chatbot era, more than 90% of inference finished inside the GPU. But as agents started looping on tool execution and result verification, the bottleneck moved to the host CPU. Cores per gigawatt quadrupled, and lead times stretched to 26 weeks. Now what is getting scarce is not the GPU but power, and operations."
seo_title: "The AI Agent Bottleneck: The Day It Left the GPU"
seo_description: "Agent AI is exploding host CPU demand and pushing power and operations into the new bottleneck. This post follows that signal in today's news, and why Paxis, which governs the whole execution environment, is drawing attention."
date: 2026-09-03
last_modified_at: 2026-09-03
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/agent-needs-cpu-not-gpu/"
tags:
  - agentic-ai
  - cpu-shortage
  - datacenter-power
  - ai-infrastructure
  - agentops
  - inference-cost
  - sovereign-cloud
categories:
  - agentops
---

One number The Daily dropped last week: how many CPU cores a 1GW AI data center needs. In the chatbot-centric era, it was 30 million. But as we move into agentic AI, into multi-agent orchestration, it balloons to 120 million. That is 4x. And notice that this is no longer a story about GPUs.

For more than two years, when we talked about AI infrastructure, the first thing we looked at was the GPU. How many H100s, how many B200s, how much HBM. There was an era when the GPU was treated as if it were the whole of AI. But the bottleneck of agent AI has already shifted. What is getting scarce is the host CPU that actually runs the agents, and the power, memory, and operations around it. The more agents you run, the sharper that fact becomes.

![An image visualizing the concept that the chip agents need most is not the GPU](/assets/images/agent-needs-cpu-not-gpu-hero.webp)
*The core concept of this post, visualized.*

## The Day the Bottleneck Left the GPU

The reason the shift happened is the difference in the loop between a chatbot and an agent. In a chatbot, more than 90% of LLM inference finished inside the GPU and the HBM. You put in a prompt and take out an answer, and that is the whole job. The host CPU only needed a minimum spec. Agents are different. They call external APIs, execute tools, and verify results. And they keep looping through that. The host CPU, which was close to a peripheral part in a chatbot, becomes the central component that directs the orchestration in an agent. Once repetition enters, the bottleneck shifts to the side that has to process what is directed.

According to TrendForce, the CPU-to-GPU ratio in enterprise agent clusters is converging from the traditional 1:8 toward 1:1 through 1.4:1. That works out to 86 to 120 CPU cores per GPU. And where does the latency come from? The Daily's report says that more than 80% of the latency in composite agent work occurs in the host CPU's preprocessing, I/O scheduling, and context switching. In a world where the agent calls a tool, checks the result, and calls another tool, the GPU does its computation in a moment and waits while the CPU keeps moving. IDC warns that a shortage of host CPU cores can drop system efficiency by up to 40%. The assumption that you only need GPUs, the belief that that is enough, is falling apart.

## The CPU Shortage Is Already a Market

This is already a market. The 2026 server CPU production capacity of Intel Xeon 6 and AMD EPYC has been sold out in full to hyperscaler long-term agreements, the LTAs. Xeon lead times have stretched from the previous 1 to 2 weeks to as long as 22 to 26 weeks, and order fulfillment is around 40%. Even with Intel and AMD raising server CPU unit prices by 10 to 20%, the scramble for supply does not stop.

A structural reason sits on top of the shortage. TSMC leading-edge process slots and high-layer FC-BGA substrate shortages hit at the same time. AMD already declared the return of the CPU at "Advancing AI 2026" in July, unveiling EPYC Venice, up to 256 cores on TSMC 2nm, the rack-scale solution Helios, and the MI400 series. It even proposed three layers of roles: agent sandbox, AI head node, and general-purpose enterprise CPU. NVIDIA and Arm are stepping in with their own new server CPU architectures. Everyone is betting that the value of the CPU is coming back. Boston Consulting, BofA, and others project the 2030 server CPU market at $125 billion to $210 billion.

## What Runs Short Next Is Power

If the CPU is the first bottleneck, power is the second. LS Electric and KT Cloud recently signed an MOU on AI data center infrastructure. The core is the modular data center. Server rooms, power supply chains, and cooling modules are precisely built in a factory and then assembled on site, which cuts construction time sharply compared to conventional reinforced concrete building. Power equipment such as ultra-high-voltage transformers and gas-insulated switchgear has risen to become the bottleneck that determines how fast data centers can expand.

The government's 1,500 trillion won, three major mega projects are on the same line. Of that, AI data centers get 550 trillion won: stage one builds 8.4GW by 2029, and SK plans to expand to 15GW by 2035. But as Tokenpost points out, the crux is "power and site." Power, water, transmission grid, industrial complex permits, all of them are bottlenecks. What we are now wiring in is not only chips but enormous loads that pull tens or hundreds of megawatts. The competition over "how many GPUs" has become a competition over "how many gigawatts of power."

## Costs Build Up in the Supply Chain Too

The story does not end with CPUs. Hardware prices are rising at the same time. US Secretary of Commerce Howard Lutnick warned that "if you produce in the US, tariffs are waived; if not, you pay a price," previewing new semiconductor tariffs tied to place of production. The US has already imposed a 25% tariff on NVIDIA H200-class high-performance chips since January this year, and the scope may widen to finished products that contain semiconductors, such as laptops, data center servers, and game consoles. The scale of the pressure is not small either. The US side says the promised investment for semiconductor production inside the US is 1.2 trillion dollars, and US share of semiconductor production is moving from under 2% toward 40%. This tariff design, which Secretary Lutnick confirmed is "completely accurate," cites TSMC's $265 billion Arizona facility and Micron's $250 billion investment as "evidence that the policy works." When hardware unit prices go up, inference token prices move with them.

The Bank of Korea's warning is on the same line. Korea's edge in advanced memory will widen for another 3 to 5 years, but China's overall ecosystem build-out is a long-term threat. China's semiconductor exports doubled year over year from January to July this year, and Korea's semiconductor exports to China account for 37% of total exports. HBM is a bottleneck for both inference and training. In the end, the cost of the execution environment is rising from four directions at once: CPU lead times, power bottlenecks, chip tariffs, and memory structure. This is not a question of buying one chip or not. It is the price of the entire environment that carries and runs it going up.

## And Who Does the Operating

On top of CPUs and power, what else is scarce? "Operations." In a CNCF survey cited by The Daily, 82% of companies using containers run Kubernetes in their operating environment, and 66% of companies operating generative AI models manage inference workloads on Kubernetes. But the Linux Foundation's survey paints a different picture. Adoption of AI and machine learning open source is 40%, yet only 34% of organizations have a clear strategy, and only 26% run a dedicated OSPO. Meanwhile, 71% of respondents expect technical support within 12 hours. Adoption is running ahead, and the system is not keeping up.

A concrete case is right next door. Bespin Global's US subsidiary joined forces with Niolox to take on the AI transformation of transportation infrastructure. Annual revenue from toll roads in the US is $25 billion, and 20% of it is being lost. The core value proposition is to recover that loss with AI, and Niolox won a 10-year, $12 million contract from the Georgia Department of Transportation. The structure worth watching is this. Instead of selling one model, one GPU, it locks down the "operations" of a specific execution environment with a 10-year contract. In Korea, players are entering with managed operations to fill the same gap. Mantech Solution's Accordion 3.0, Namoo AX, NHN Cloud's Hyperframe, all part of that flow. "Operational responsibility" is no longer a technical issue. It is a commercial one.

Jensen Huang's remarks are a signal too. The future of AI will shift from a single space to a "highly distributed" structure spread across multiple data centers and clouds, he said. And in this fragmented network, he emphasized that security controls and clear access permission boundaries are essential to stop unauthorized data leakage. NVIDIA's "Equinix Inference Exchange," proposed with Equinix and Together AI to connect scattered data and AI like a stock exchange, is in the same context. The moment a layer that neutrally arbitrates distributed inference steps to the front, "where to run" becomes a decision variable as important as "which model to use."

## Put the Paradox on the Table

So let us put the paradox on the table. On one hand, token prices are nosediving. Grok 4.6's output is $6 per 1 million tokens, about a fifth of the $25 for Claude Opus 5. Alibaba's Qwen3.8-Max is $5 on a blended basis, about a tenth of the price, and took first place in the web development category of Code Arena. Grok 4.6 was added to AWS Bedrock's cross-region inference environment within a week of release, and models have become menu items on neutral platforms. That means the criterion for selection is shifting from loyalty to routing. "Intelligence" itself is, literally, becoming cheap.

But on the other hand, the cost of running agents does not fall with it. The TCO of an agent workload is no longer determined by token unit price alone. Execution efficiency per CPU core, scheduling, power, tariffs and memory structure, operational governance, all of them determine the price together. The cheaper intelligence gets, the more the value of "running it stably, safely, and with proof" rises. The day the AI infrastructure bottleneck moved from chips to the execution environment is today.

## In This World, Execution Itself Becomes the Product

In exactly this world, "agent-native cloud" is no longer a slogan. ThakiCloud's Paxis is an agent-native cloud that has already reached official product v1.1 GA. It is a platform that treats "execution" itself as a first-class resource.

Today, when what is scarce is the entire execution environment, what Paxis offers is not "one more GPU" but an answer to "where, how, and with what proof do you run it." Isolated sandboxes and policy gates keep agents running in a controlled environment, and autonomy comes with governance from L0 through L3 and audit logs, so who did what is left as evidence. Per-task model selection, CostRouter, routes cost-sensitive nodes to cheap tokens like Grok and Qwen, defending the cost of the same workflow while execution environment prices rise. MCP connectors and the skill market orchestrate tool execution efficiently, and sovereign, on-premise K8s execution lets you run the same workflow as-is even under constraints like power or data sovereignty.

The pain in the enterprise that today's news reveals converges precisely here. Finance and public sectors that need audit and proof, regulated industries that demand data sovereignty, and everywhere that execution costs are rising. The answer Paxis offers corresponds to that list of pains one by one.

The AI infrastructure competition is being rewritten. The era where the side with the most GPUs always wins is already over. In a world where CPUs and power are tight and operations are constrained, the side that runs agents stably, safely, and with proof is the side that cuts costs and earns trust. The day the bottleneck changed its owner, is this the new standard?

## References

This post synthesizes the following news coverage.

- The Daily, [[CPU Crisis Alert ③] "Cores per 1GW surge 4x"... the host CPU that agentic AI broke...](https://www.ddaily.co.kr/page/view/2026090111255746435)
- The Daily, ["What matters more than the AI model is operations"... Who is responsible for open source infrastructure?](https://www.ddaily.co.kr/page/view/2026090217393002752)
- Asia Economy, [LS Electric joins hands with KT Cloud to target AI data center infrastructure](https://view.asiae.co.kr/article/2026090307474340291)
- Tokenpost, [1,500 trillion won three major mega projects: power and site are the crux](https://www.tokenpost.kr/news/policy/401980)
- Kyunghyang Shinmun, [Lutnick "Preparing new semiconductor tariffs... If you do not make it in the US, you pay the price"](https://www.khan.co.kr/article/2026090307474340291)
- Yonhap InfoMax, [BOK "Korea-China advanced memory gap to widen in the next 3 to 5 years... a threat in the long term"](https://news.einfomax.co.kr/news/articleView.html?idxno=4433198)
- Economic Review, [Bespin Global US subsidiary joins Niolox to support AI transformation of transportation infrastructure](https://www.econovill.com/news/articleView.html?idxno=749709)
- Yonhap News, [Jensen Huang "Adopting AI systems should be done as carefully as hiring a new employee"](https://www.yna.co.kr/view/AKR20260903017300091?input=1195m)
- IT Chosun, [Musk's AI 'Grok' boosts performance and expands ecosystem... The speed of the pursuit at the top](https://it.chosun.com/news/articleView.html?idxno=2023092169337)
- WikiTree, [Alibaba's Qwen3.8-Max-0902, at the same version, surpasses Claude Opus 5 with a price that is...](https://www.wikitree.co.kr/articles/1156911)
