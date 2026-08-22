---
title: "Deferred MCP Tools: If the Agent Doesn't Know the Name, Search Won't Find It Either"
seo_title: "Measuring Cold-Start Blindness in Deferred MCP Tool Loading | ThakiCloud Research"
seo_description: "In agent harnesses that defer-load MCP tool schemas, we measured cold-start blindness, where a tool the agent doesn't know by name never surfaces in search, and quantified it with BM25. We propose a hybrid loading policy based on the results."
excerpt: "Deferred loading, fetching a tool's schema only when needed instead of putting every schema in the prompt up front, saves a lot of tokens. The problem is when the agent doesn't know the tool exists at all. In our measurements, 88.5 percent of vocabulary-mismatched tools never appear in the top 5 search results."
date: 2026-08-03
tags: [tool-use, MCP, deferred-loading, agent-harness, tool-discovery, cold-start-blindness, cost-quality-tradeoff, LLM-agents, token-efficiency]
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/deferred-tool-schema-discovery-cost/"
audiobook: "https://drive.google.com/file/d/1RsLLIQUcJdaBEb-djKa-MtKxsrYg7Mr4/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
published: false
---

If you run an agent harness wired to multiple MCP servers and hundreds of skills, and you already use, or are considering, deferred loading, fetching tool schemas only when needed instead of surfacing all of them up front, to save on tokens, this post is for you. This research does not measure how many tokens deferred loading actually saves. It measures whether an agent can find, through search, a tool it does not already know exists. The short answer: when a tool's name and the task's vocabulary do not overlap, search barely works at all.

![Illustration of the core idea of Deferred MCP Tools: If the Agent Doesn't Know the Name, Search Won't Find It Either](/assets/images/deferred-tool-schema-discovery-cost-hero.webp)
*A visual metaphor for the article's key idea.*

## The problem: the tool is there, so why can't it be used

The problem comes into focus when you picture an agent inside a large production harness asking, "if I change this function's signature, what breaks?" The harness already has a code-graph exploration tool wired in that computes exactly this blast radius over a symbol graph. The tool is live and one call away. Yet the agent never uses it, because the harness defer-loads tool schemas: ordinarily only the name is visible, and an explicit search call has to come first before the tool can actually be invoked. The agent phrases its own query, something like "find everywhere this function is called and see what breaks." That sentence shares almost no vocabulary with a tool named `codegraph_impact`, described in terms of blast radius over graph nodes. The search returns irrelevant results, and the agent falls back to a manual grep loop, spending far more tokens for a weaker answer. No error was ever raised. Functionally, the tool simply did not exist.

This study calls this failure mode cold-start tool blindness. Anthropic's code-execution-with-MCP design reported cutting tool-related context for a representative task from roughly 150,000 tokens to roughly 2,000, a 98.7 percent reduction. Exposing tool identity lightly and loading definitions only on demand is becoming the standard for production harnesses. But nearly all existing tool-retrieval research addressing this trend assumes the query is already well formed, that the agent knows at least roughly what it is looking for. That is a reasonable assumption for a benchmark, but in production it is exactly the assumption deferred loading removes. With the schema hidden, the name is the only signal, and if the agent's task vocabulary does not overlap with the tool's naming vocabulary, no retriever, however good, has anything to rank.


## What was measured, and how

This study used the real registry of 26 deferred-loading tools from an actual production Claude Code based harness that hosts more than 1,600 skills alongside multiple MCP servers: 17 task-session management tools (`CronCreate`, `Monitor`, `SendMessage`, and others), 7 code-graph exploration tools (`codegraph_callees`, `codegraph_impact`, and others), and 2 general web tools (`WebFetch`, `WebSearch`). To check whether corpus size affects the results, unrelated synthetic dummy tools were added to scale the corpus to four sizes: 26 (no dummies), 61, 150, and 300.

The core manipulation was writing two task sentences for every tool. Aligned tasks reuse the vocabulary that appears in the tool's own name and description, simulating a case where the agent has some idea what it is looking for. Unaligned tasks describe the same need using completely different vocabulary, simulating an agent that has no idea the tool exists and can only phrase the need in its own words. In both conditions, search queries are built only from the words in the task sentence; the tool's actual name is never revealed. To confirm the manipulation worked, token overlap between the query and the target tool's text was measured: the aligned condition averaged 6.42 overlapping tokens, the unaligned condition averaged 0.038, roughly two orders of magnitude apart. Search was run with deterministic BM25, and every measurement here was taken on CPU containers, no GPU required.

## Core result: alignment creates a cliff

Across every corpus size, the aligned condition was always perfect. For all 26 tools, at corpus sizes of 26, 61, 150, and 300, BM25 ranked the correct tool first for aligned-task queries. When the tool's name and the task vocabulary overlap, deferred loading works exactly as advertised.

The unaligned condition collapses. Recall@1 is 0.0769, finding only 2 out of 26. Recall@3 is identical at 0.0769; widening the search window to the top 3 finds nothing extra. Only at Recall@5 does it move, to 0.1154, or 3 tools, but the remaining 23 (88.5 percent) never once appear in the top 5. And this holds regardless of corpus size, identical at 26 tools and at 300.

![Deferred Recall by Vocabulary Alignment and k](/assets/images/posts/research/deferred-tool-schema-discovery-cost/recall-transition.webp)
*This chart shows the paper's measured results. Aligned queries hold Recall@1=1.0 at every k, while unaligned queries collapse to 0.0769 at the same k, and widening the search to k=5 recovers only one additional tool.*

Same retriever, same 26 targets, same corpus, and the gap between 1.000 and 0.0769 is not a modest drop in performance, it is closer to a phase transition. The only variable that produces the difference is whether the task sentence happens to share vocabulary with the tool's name, and by the very design of a deferred-loading policy, the agent has no way to know that in advance.

## The tools that disappear, and a flat failure regardless of scale

Breaking results down by individual tool makes the mechanism clear. `CronCreate` and `CronList` are among the few tools that stay ranked first even under the unaligned condition, because scheduling-related words rarely disappear no matter how you rephrase a recurring task. In contrast, the 7 code-graph tools (`codegraph_callees`, `codegraph_impact`, and others) land at ranks 21 through 26 out of 26 under unaligned queries, near the bottom of the pack. Natural developer phrasing like "explore the code," "find who calls this function," or "what breaks if I change this" never contains words like `codegraph`, `callees`, or `impact radius`. Those words exist only inside the tools' own names and descriptions. It is precisely the code-graph family that is hardest to guess the existence of and also has the most specialized vocabulary, the worst possible combination for a deferred-loading policy.

An even more counterintuitive observation is that unaligned recall is completely independent of corpus size. Recall@1 stays at 0.0769 and Recall@5 stays at 0.1154 whether the corpus has 26 tools or 300.

![Unaligned Recall Is Flat Across Corpus Scale](/assets/images/posts/research/deferred-tool-schema-discovery-cost/corpus-scale-flatness.webp)
*This chart shows the paper's measured results. Adding 274 dummy tools leaves the unaligned condition's Recall@5 completely unmoved at 0.1154, showing that the failure is caused by vocabulary mismatch itself, not dilution in a haystack.*

Because BM25 only scores documents that share vocabulary, dummy tools with no shared vocabulary at all converge to scores near zero and neither displace nor compete against the correct tool's rank. A tool ranked 24th out of 26 stays 24th among the tools that actually receive nonzero scores, even after adding 274 dummies. In other words, this failure is not about a tool getting lost in a crowd, it is that the query and the tool live in entirely different vocabulary spaces from the start. That means the first fix people usually reach for in retrieval problems, trimming the tool list, does not mitigate this failure at all.

## What the token cost actually means

The token savings themselves are not overstated. At a corpus of 300, aligned queries save 91.4 percent compared to preloading everything.

![Token Cost per Query vs Corpus Size](/assets/images/posts/research/deferred-tool-schema-discovery-cost/token-cost-by-scale.webp)
*This chart shows the paper's measured results. At a corpus scale of 300 tools, aligned queries save 91.4 percent of tokens compared to preloading everything, but that savings only holds under the condition of vocabulary alignment.*

The problem is that this savings is entirely conditional. Under the unaligned condition, the token cost of attempting a search is incurred even when the search fails. The paper summarizes this as a single tool-family-level statistic: the total token cost of attempting search across all 26 tools, divided by the number of tools actually recovered (2 out of 26). That is equivalent to multiplying by the inverse of the recovery rate, a factor of 13, and this amortized cost per success exceeds the full-preload cost at every corpus size tested. This is not a retry cost. Deterministic BM25 fails the same way every time for the same query, so searching again does not help. In the unaligned regime, deferred loading is not buying a discount, it is spending tokens on a search that mostly fails, and a tool that cannot be found is not degraded, it is functionally absent.

## What carries over to company, society, and science

These results are useful in three directions. At the company level, they give a data-backed default policy for a harness that keeps growing past 1,600 skills and multiple MCP servers: which tools to preload immediately and which to defer. The paper offers exactly this offline-computable criterion: write a deliberately vocabulary-mismatched task sentence for each tool and check whether that tool survives in the top k. Tools that do not survive, in this measurement the 7 code-graph tools were the representative case, should be preloaded immediately as an always-visible small set. At roughly 80 tokens per schema, preloading all 7 costs about 560 tokens per turn, negligible next to the 24,800 tokens it would take to preload all 300 tools. Conversely, the long tail where a tool's vocabulary is already naturally embedded in task vocabulary, like the scheduling family, can safely stay on deferred loading. A cheaper complementary fix is vocabulary augmentation: adding a few task-side synonyms to the one-line description in the deferred index.

At the society level, as more agent platforms adopt on-demand tool discovery to cut costs, characterizing in advance where deferred loading quietly degrades performance helps others avoid this class of invisible failure before it reaches production. At the science level, this work extends the assumption common in existing skill- and RAG-routing literature, that queries are already well formed, into the domain of tool-schema retrieval, naming and measuring the situation where the retrieving agent may not even know a candidate tool exists in the first place. Earlier work on the same harness, examining BM25 search over the skill layer, found that synonym expansion in the retriever itself was a more decisive bottleneck on routing quality than query decomposition, which sits at exactly the same layer as the vocabulary-mismatch mechanism observed here.


## Limitations

The study itself flags that its numbers are a lower bound. The measurement generously assumes the agent always honestly attempts a search. A more severe variant of cold-start blindness, where the agent never even suspects a tool might exist and so never attempts a search at all, is not captured by recall metrics and falls outside the scope of this measurement. In real deployments these two factors co-occur, so the numbers reported here should be read as a floor on total cold-start blindness, not an estimate of it.

The finding that recall stays flat regardless of corpus size also deserves a careful reading. The dummy tools here were deliberately built to be topically unrelated to both the queries and the targets, which cleanly isolates the vocabulary-alignment effect but is not representative of a real MCP registry. In practice, independently built servers frequently reuse generic vocabulary like `search`, `list`, `get`, `status`, and `run`, and such dummies can score meaningfully against real queries and push an already low-ranked target further down. Under that condition, recall could get worse with scale rather than staying flat. Also, this measurement used only one lexical retriever, BM25, and recall is ultimately a proxy for actual task success. A dense, embedding-based retriever could bridge vocabulary mismatches semantically, for example connecting "what calls this function" to "callers of a symbol," and plausibly raises unaligned recall substantially, but a tool described in implementation vocabulary can still be semantically distant from user-need vocabulary, so the phenomenon itself is not expected to disappear, and this remains an untested claim. Finally, this 26-tool base corpus comes from a single production harness, and the fact that one of its three functional families, code-graph, uses especially specialized vocabulary is exactly what determines the specific figure of 88.5 percent. The qualitative claim, that vocabulary distance between task phrasing and tool identity causes near-total search failure under deferred loading, does not depend on this composition, but the exact numbers may differ in other harnesses.

Full paper details are available at the following link: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-03-deferred-tool-schema-discovery-cost](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-03-deferred-tool-schema-discovery-cost)
