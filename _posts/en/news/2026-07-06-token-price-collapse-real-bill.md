---
title: "Tokens Are Converging on Free, So Why Isn't the Bill Shrinking"
excerpt: "$0.11 per million tokens. On the very day model prices collapsed, NVIDIA put a new price on protecting inference. Value does not vanish, it just relocates. Today's news points to exactly where it moved."
seo_title: "In the Age of Token Price Collapse, Where Does the Real Enterprise AI Bill Go"
seo_description: "China's ultra-cheap tokens and NVIDIA's confidential GPU computing moved in opposite directions on the same day. As models become commoditized, what enterprises actually pay for shifts toward routing, isolated execution, and auditability. Read through the lens of an agent-native cloud."
date: 2026-07-06
last_modified_at: 2026-07-06
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
  - news
canonical_url: "https://thakicloud.github.io/en/news/token-price-collapse-real-bill/"
---

![Illustration of the core concept](/assets/images/token-price-collapse-real-bill-hero.png)

$0.11 per million cached input tokens. That is the price z.ai set for its GLM-4.5 model on frequently repeated inputs, with standard input priced at $0.6 per million tokens and output at $2.2. Compare that to frontier US models, whose input pricing still sits in the several-dollar range, and the gap is stark. Chinese models such as MiniMax, DeepSeek, Qwen, and Kimi have joined the same trend, pricing input in the ultra-low $0.1 range. Some tallies now show that Chinese models' share of global token consumption, which stood at under 10 percent in early 2025, had climbed to around 50 percent by mid-2026. Looking at the numbers alone, the conclusion seems simple: models have become commodities, and prices are racing toward zero.

Yet that same morning, another piece of news arrived pointing in exactly the opposite direction. NVIDIA announced that its Blackwell GPU's confidential computing technology protects enterprise data and proprietary model weights during inference at the hardware level. On one side, the cost of running a model is collapsing. On the other, a new price is being attached to running that model safely. This disconnect is the real question today's digest raises.

## Two Opposing Signals on the Same Day

The logic of the price war is clear. Chinese models have swept the top of OpenRouter's weekly token usage rankings, driving real adoption, and in response, both OpenAI and Anthropic are reportedly reviewing cuts to their own token pricing as a defensive move. Frontier labs heading toward IPOs are being valued at $800 billion to $900 billion, and if service prices keep falling sharply, the story propping up those valuations starts to wobble. Morgan Stanley estimates that cumulative global AI data center construction spending will reach $2.9 trillion by 2028, and if token prices drop to a tenth of their current level, the math for recouping that enormous capital becomes far harder. So a natural picture emerges: the cheaper tokens get, the more anxious frontier labs become, while adopting enterprises grow more pleased.

The confidential computing news cracks that picture. NVIDIA's approach works by having a remote attestation service cross-check GPU hardware reports and CPU trusted execution environment measurements against a reference integrity manifest, blocking any unverified execution environment from ever touching model decryption keys or sensitive data. It extends confidential computing, which AMD and Intel had already offered on the CPU side, up into the GPU itself, and the US company Corvex has already deployed it in production on HGX B200 systems. That is a signal the technology has moved past the experimental stage into commercialization. What matters here is the assessment that throughput loss is negligible. In other words, a mechanism now exists that proves trust without sacrificing performance.

Put the two pieces of news side by side and they collapse into a single sentence. The price of calling a model is falling, but the price of trusting and using that model safely stays the same, or even rises. Value has not evaporated. It has simply moved.


![Diagram of the shift in value](/assets/images/token-price-collapse-real-bill-diagram.svg)

*Token prices converge toward zero, but value migrates to three bills in the execution layer: cost control, safe execution, and auditability.*

## Value Doesn't Disappear, It Relocates

A third piece of news confirms this shift once more. Amazon Mechanical Turk, the crowdsourced labeling platform the company has run since 2005, will stop accepting new customers starting July 30, 2026. A service that had long served as the standard channel for AI training labeling work, such as image classification, audio transcription, and data cleaning, has effectively entered a frozen state. Behind this lies one bitter data point. A 2023 analysis found that 33 to 46 percent of workers on the platform were already using large language models to complete their tasks. Models had quietly taken seats meant for human labelers.

That does not mean the work of labeling itself has disappeared. The market is still growing, estimated at $2.3 billion to $2.8 billion in 2026. But the axis of growth has shifted, from simple crowd labor toward a hybrid pipeline in which AI produces a first draft and specialized human reviewers check it. Here too, value has not vanished, it has moved from simple repetitive labor up into the higher-order work of review and quality assurance. Whether it is tokens or labeling, the pattern is the same. The commodity parts converge on free, and value climbs into the process that makes those results safe to trust.

This lens quietly overturns yesterday's conventional wisdom. "Which model is the cheapest and smartest" is no longer where the real contest lies. Cheap, capable models are now abundant across many countries. The real question has shifted to: "How controlled is the cost, how safe is the execution, and how provable is the process when we run that model on our own data." That is where the bill gets issued all over again.

## The Bottleneck Keeps Moving Too

This shift in value is not confined to software. Today's digest also carries news that Vertiv is building a new manufacturing facility in Malaysia to expand its power and cooling supply chain for AI data centers, alongside a report that electronics and refining companies are racing to stake out positions in immersion cooling. Just a few years ago, the sole bottleneck in AI infrastructure was the GPU. Secure the chips, people said, and everything else would follow. But now that high-density GPU clusters generate heat that must be cooled with water, power and cooling have become the new gatekeepers.

The pattern is identical to what we have already seen. As a resource becomes commoditized, its price falls, and value migrates to the process that makes that resource actually usable in practice. When GPUs were scarce, GPUs set the price, but now that GPUs are abundant, it is the power and cooling needed to run them safely around the clock that sets the price. That is exactly the same logic as tokens becoming abundant while the layer that consumes them safely and in a controlled way sets the price. Whether in physical infrastructure or inference software, the bottleneck always climbs one level higher.

## Three Places the Bill Has Moved To

The first is cost control. Domestically too, a growing number of companies that have adopted large language models are running into unexpected monthly costs in the thousands of dollars from unmanaged token calls. Insisting on a single top-tier model means the bill does not shrink, even in an era of cheap tokens. This is why routing, which swaps in real time between low-cost open-source models and high-performance models depending on the nature of the task, is becoming a competitive edge. That cheap raw material is abundant, and that it gets used without waste, are entirely different matters.

The second is safe execution. Sectors handling sensitive data, such as finance, government, manufacturing, and healthcare, have long been reluctant to put data on external GPU infrastructure because of regulation. Once confidential computing is verified, this barrier lowers, but a new checklist item appears at the same time. Beyond simply which cloud to use, companies must now examine, at the adoption stage, exactly how data and model weights are isolated and verified the moment inference runs. Running a cheap model in an unsafe environment can cost more than whatever was saved on token prices.

The third is auditability. As the labeling case shows, this is an era in which results cannot simply be taken on faith. A model quietly does work that was supposed to be done by a person, and the fact only surfaces later. If there is no record of what basis a model used, which tools it called, and what decisions it made, there is no way to later prove the reliability of an answer that was obtained cheaply. This problem grows even larger the moment companies start swapping between multiple models to save on token costs. If Model A handled a task yesterday and Model B handles the same task today, there needs to be a record somewhere explaining the difference between the two results. In regulated industries especially, this record is not optional, it is a condition of adoption. The freedom to use cheap models liberally only holds up safely on top of a record that lets every use be traced back in full.

## The Lens of an Agent-Native Cloud

Bringing these three bills together in one place reveals that they are not separate problems but belong to a single layer. Not the layer of choosing a model, but the layer of actually executing that model. ThakiCloud's Paxis is easiest to understand through this lens. Paxis is an agent-native cloud that treats skills, tools, policies, and audit logs as first-class resources. The three bills just described are precisely the design axes of this product.

Cost control is handled by a cost router that selects the appropriate model for each task. The era of cheap tokens is, if anything, increasing demand to run low-cost open-source models like DeepSeek or Qwen directly in sovereign, on-premises environments. Safe execution is handled by isolated sandboxes and policy gates. Autonomy is tiered from L0 to L3, and risky actions are filtered by policy before they can run. Auditability is the responsibility of the audit log, which records which skills and which MCP connectors an agent used to execute what. The key point is that this is not a feature bolted on afterward, but something that exists as a resource from the start. That all three run together on sovereign, on-premises Kubernetes also connects directly to today's news, because this is exactly the place where a cheap model can be run safely and at controlled cost, without ever sending data outside the country's borders.

Today's digest also includes news of a government drive to invest 1,000 trillion won in sovereign AI data centers, a report on 312 trillion won in private investment across the Yeongnam region, and Naver's efforts to monetize HyperCLOVA X. All of these are stories about growing the size of infrastructure. But no matter how large that infrastructure grows, if the layer that runs cheap models on top of it safely, at controlled cost, and with provable execution is left empty, the bill will keep leaking out. The trend of tokens becoming free cannot be reversed. If so, the remaining contest will be decided in the place that does not become free, that is, in how execution itself is handled.

## A Remaining Counterargument

Of course, this logic has a weak point. One could argue that if cheap tokens become good enough and cheap enough, that same commodity model might eventually handle even the upper-level work of safe execution and auditing on its own. Indeed, this is exactly what has already begun happening with labeling review, where models have started taking over the check itself. This counterargument deserves serious consideration. But one thing gets in the way. The moment we let a model review itself and prove its own execution, we lose any external way to verify the basis for that judgment. Regulators and auditors do not accept a model's self-reporting as evidence. Value remains in the execution layer not because the technology is lacking, but because trust ultimately comes from independent records and independent control. That is why this layer does not easily disappear no matter how much better models become.

## Closing

This story started with a single price tag. The figure $0.11 per million tokens shows just how quickly the price of a model is collapsing. But the confidential computing news and the labeling shutdown news that arrived on the very same day tell us that this collapse is not the disappearance of value, but its relocation. The bill companies will pay going forward will not be written against which model they call, but against how they run that model. Read today's news as a map of that migration path, and it becomes a little clearer what to prepare for next.

## References

- GLM-4.5 API token pricing (standard input $0.6, output $2.2, cached input $0.11 per million tokens): [z.ai pricing documentation](https://docs.z.ai/guides/overview/pricing)
- NVIDIA Blackwell confidential computing and remote attestation (near-zero overhead): [NVIDIA Developer Blog](https://developer.nvidia.com/blog/hardware-rooted-ai-security-that-wont-slow-you-down)
- Corvex verifies production deployment of confidential computing on NVIDIA HGX B200: [PR Newswire](https://www.prnewswire.com/news-releases/corvex-among-the-first-companies-to-achieve-verified-production-deployment-of-confidential-computing-for-ai-on-nvidia-hgx-b200-systems-302702992.html)
- Amazon Mechanical Turk to stop accepting new customers starting July 30, 2026: [TechCrunch](https://techcrunch.com/2026/07/05/amazon-will-stop-accepting-new-customers-for-mechanical-turk/)
- 33-46% of Mechanical Turk workers used LLMs (2023 study): [arXiv:2306.07899](https://arxiv.org/abs/2306.07899)
- Morgan Stanley estimates cumulative global AI data center capex of about $2.9 trillion by 2028: [Crypto Briefing report](https://cryptobriefing.com/morgan-stanley-data-center-capex-2028/)
- Data labeling market estimated at about $2.6 billion in 2026: [Mordor Intelligence](https://www.mordorintelligence.com/industry-reports/data-labeling-market)
- Vertiv expands AI data center power and cooling supply with new manufacturing facility in Johor, Malaysia: [Vertiv Newsroom](https://www.vertiv.com/en-us/about/news-and-events/corporate-news/2026/vertiv-increases-manufacturing-capacity-with-new-facility-in-malaysia-to-support-growing-demand-for-ai-and-digital-infrastructure-across-asia/)
