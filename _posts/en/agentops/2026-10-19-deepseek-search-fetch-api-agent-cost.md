---
title: "A Search Unit Price Lands on the Agent Loop"
excerpt: "DeepSeek shipped Search and Fetch as standalone APIs, priced at $0.75 per 1,000 successful requests each. The two steps an agent takes to reach the web are now line items, so the loop's cost now sits on the ledger next to the model's tokens. Billing starts November 1."
seo_title: "DeepSeek Search and Fetch API, $0.75 per 1,000 calls | ThakiCloud"
seo_description: "DeepSeek Search and Fetch as standalone APIs, $0.75 per 1,000 successful requests each, billing from November 1, 2026. Why the web-grounding step of an agent loop becomes its own cost line, and what that means for agent tool pricing, through a Paxis lens."
date: 2026-10-19
last_modified_at: 2026-10-19
author_profile: true
toc: true
toc_label: "Table of contents"
toc_icon: "robot"
tags:
  - deepseek
  - search-api
  - agent-rag
  - tool-cost
  - paxis
  - agentops
  - rag
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/deepseek-search-fetch-api-agent-cost/"
---

If you run agents in production, this release adds a new line to the cost table. Put bluntly: DeepSeek shipped Search and Fetch as standalone APIs, so the two steps an agent takes to reach the web are now individual products, priced at $0.75 per 1,000 successful requests each.

![An abstract isometric image of a search node fanning out to document nodes that feed an agent loop](/assets/images/deepseek-search-fetch-api-agent-cost-hero.webp)
*The concept of an agent's two web-reaching steps separating into their own cost line items.*

## Why read this

If you compute the cost of an agent loop using only the model's token price, this post changes that calculation. The path by which an agent pulls an answer from the web usually splits into two steps, a search and a fetch. Until now those two steps were scattered across individual search vendors' APIs, so they were hard to aggregate into a per-loop cost. DeepSeek bundling the two steps into one set under the same pricing structure means the separation of agent cost is now sharper. Billing starts November 1, 2026 (00:00 Beijing time).

## Overview

For an agent to use real-time information it needs two actions. A search that finds a source, and a fetch that pulls the source's body. The two are different in nature. Search takes a query and returns a list of results; Fetch takes a URL and returns a document. Until now the search API sat with vendors like Brave and Exa, and the fetch was done through crawling or a separate tool.

DeepSeek's Search and Fetch APIs bundle these two actions into one set and bill per request. Both APIs are $0.75 per 1,000 successful requests. A failed request is not billed. This is what matters in agent cost: even if empty results are mixed into the loop, the bill drops by that proportion.

## Search and Fetch, what is the price

Per DeepSeek's official API documentation, Search and Fetch are standalone APIs billed per request. Both are $0.75 per 1,000 successful requests.

| Item | Value |
|---|---|
| Search | $0.75 per 1,000 successful requests |
| Fetch | $0.75 per 1,000 successful requests |
| Billing starts | 2026-11-01 00:00 (Beijing) |
| Billing unit | successful request |

If you use search and fetch together in one cycle, that is roughly $1.50 per 1,000 calls. Some coverage says the price is below the search API pricing of Brave and Exa. The per-vendor comparison figures are not in DeepSeek's official release, so this is treated as [estimated].

Around the same time, DeepSeek reportedly also shipped a model update, V4.1-Flash-1017. A search API and a model update landing in the same week suggests the direction is to attach search to the model loop an agent runs.

```mermaid
flowchart TB
    A[Agent loop] --> B[needs web grounding]
    B --> C[Search API query]
    C --> D{result list}
    D --> E[Fetch API URL]
    E --> F[document body]
    F --> G[LLM reply]
    G --> A
    C -.1,000 successful, $0.75.-> H[cost table]
    E -.1,000 successful, $0.75.-> H
    D -->|empty result| I[not billed]
```

## A new line on the loop cost

Agent cost was, until now, counted only by the model's token price. Search and Fetch were an incidental cost bolted on behind it. Because DeepSeek shipped them as standalone products, two more lines appear on the cost table next to the model tokens.

The size of those two lines depends on the nature of the loop. A question-and-answer loop that searches once is minor. An agent that checks the web at every step, or that fetches from several sources to cross-check, will grow them. The bill-only-on-success structure shines here: a loop with empty results mixed in pays only for the actual success ratio.

When you design agent cost, there is now one more question to ask. How many search and fetch calls does this loop make? If you build the agent looking only at the token price, the web-grounding cost can quietly become a significant part of the model cost.

## ThakiCloud product implications

Paxis treats the structure by which an agent calls tools as a first-class citizen. Search and Fetch becoming standalone products means that, in Paxis's tool-call layer, these two calls are now objects that pass through the cost gate.

Every time an agent calls a tool, Paxis runs it through a policy gate and an audit log. Search and Fetch enter that same flow. With the unit price of $0.75 per 1,000, Paxis can match the loop's total tool cost against a budget. You can see which agent is calling search excessively, and where fetch failures cluster, from the cost data.

The total cost of an agent loop is model tokens plus tool calls. Read both on the same ledger and you can catch the loop whose cost stays the same even after you cut tokens. A loop that checks the web often spends on search and fetch even when tokens are saved. When Paxis's observability layer shows this separation, the agent's unit price finally becomes whole.

## Limitations and counterarguments

The bill-only-on-success structure of Search and Fetch looks favorable, but the quality of the search results is separate from this price. Even a cheap search, if the results are stale, changes which URL you fetch, so you end up spending more tokens in the end. Picking a vendor on price alone brings quality problems behind it.

The $0.75 per 1,000 is on a success basis, and the number of times it returns an empty result is not billed. But if returning an empty result makes the agent search again, the unbilled call still costs loop time and model tokens. Even when there is no bill, there is a cost.

There is also no official statement that this API is instantly available in every region without capacity limits. The documentation lists a per-model concurrency limit, but Search and Fetch limits are not stated separately. As an [estimate], in a large loop the limit and latency will likely hit before the price does.

## Summary

DeepSeek shipping Search and Fetch as standalone products matters not because search is expensive, but because the two steps an agent takes to reach the web are now separated into cost. The three figures, $0.75 per 1,000 each, bill-on-success only, and a November 1 start, write two new lines on the loop cost table. There is now one more question to ask when you build an agent. How many search and fetch calls does this loop make. The cost calculation that counted only model tokens stopped being accurate the moment web grounding became a product. When a platform that treats tool calls as first-class citizens, like Paxis, adds these two lines to the ledger, the agent's real unit price becomes visible.
