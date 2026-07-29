---
title: "We Measured What It Actually Costs to Skim 1,000 Papers in Minutes"
seo_title: "Zotero AI Paper Triage Benchmark: 35s Screening vs 24M Prompt Tokens | ThakiCloud"
seo_description: "We measured the claim that a Zotero AI plugin can skim 1,000 papers in minutes. On a MacBook, text extraction ran at 76 pages per second, or 6.5 minutes for 1,000 papers. Feeding all of them to an LLM costs 24.38M prompt tokens, while embedding-based screening ranks the same library in 35 seconds."
excerpt: "Skimming and reading are different jobs. We measured where one ends and the other begins."
date: 2026-07-29
tags:
  - Zotero
  - Paper Triage
  - Embedding Search
  - EmbeddingGemma
  - PDF Parsing
  - Local LLM
  - Literature Review
  - Research Productivity
  - vLLM
  - Batch Inference
categories: [tutorials]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/zotero-ai-triage-1000-papers/"
---

Every few months the claim comes back around: bolt an AI plugin onto your reference manager and it will skim the 1,000 papers sitting in your library in a few minutes. It sounds plausible, but the compute involved swings by orders of magnitude depending on what "skim" means. So we downloaded ten real arXiv papers, timed each stage, and scaled the numbers to a 1,000-paper library.

![Abstract image of stacked paper sheets with a single sheet lit and rising](/assets/images/zotero-ai-triage-1000-papers-hero.png)

## Why this matters

This post is for researchers who keep hundreds or thousands of papers in a library and have to decide what to read next, and for ML engineers who need to stand up a document summarization pipeline internally. It is not a plugin comparison. It is an attempt to put numbers on the computation those plugins perform on your behalf. The conclusion up front: **the "1,000 papers in minutes" claim is true for screening and false for full reading, and the line between them is not drawn by the tool but by which stage you put the LLM in.** In our measurements, ranking 1,000 papers by embedding took 35 seconds. Pushing the same 1,000 full texts through an LLM piles up 24.38M prompt tokens.

## Overview

Zotero is an open-source reference manager that stores paper PDFs and bibliographic records, and a range of AI plugins have grown on top of it. PapersGPT is the best known. Its site reports 2,500 stars, offers a path to run open models such as Gemma, Qwen, and gpt-oss locally alongside commercial APIs, and advertises multi-PDF chat plus an AutoPilot mode that processes a library in bulk. Open-source alternatives exist too, such as zotero-AI-Butler, which reads incoming papers automatically and writes the summary back as a Zotero note.

If you want to know what is actually inside the shipped plugin, our [teardown of the 131MB PapersGPT build](https://thakicloud.com/tech-blog/en/dev/papersgpt-zotero-local-rag/) covers that. Where that post asks what the tool is made of, this one asks how heavy the computation it performs on your behalf really is.

These tools all sell the same value: less time spent deciding what to read. The catch is that the numbers in the marketing copy rarely say which stage they measured. Pulling text out of a PDF, turning that text into vectors and comparing it against a query, and feeding full texts to a language model are three jobs with very different price tags. The last one is far heavier than the first two combined.

So instead of evaluating the tools, we measured the computation underneath them. The sample is ten agent-related papers posted to arXiv in July 2026, and the environment is a single MacBook running Python 3.12.8. Every number below is measured in that environment; the 1,000-paper figures are arithmetic on those measurements.

## What the pipeline actually is

Paper triage usually breaks into three stages. Tools name them differently, but the work is the same.

```mermaid
flowchart TB
    A[Library<br/>1,000 paper PDFs] --> B[Stage 1<br/>Text extraction<br/>pypdf or similar parser]
    B --> C{Where does the<br/>LLM go?}
    C -->|Full text in| D[Full-summary path<br/>all 1,000 papers<br/>sent to the model]
    C -->|Head only| E[Stage 2 screening<br/>embedding vectors<br/>EmbeddingGemma-300M]
    E --> F[Cosine similarity<br/>against the query]
    F --> G[Stage 3<br/>full summary for<br/>the top K only]
    D -.24.38M prompt tokens.-> H[Summary notes]
    G -.0.49M prompt tokens.-> H
```

The branch in the middle is the whole story. Sending full texts straight to a language model and ranking cheaply first before reading a handful produce similar-looking output at wildly different cost. The "minutes" in the marketing copy almost always refers to part of the right-hand path, not the left one.

The screening stage uses EmbeddingGemma-300M, released by Google. Its HuggingFace model card shows more than 1.86M downloads per month, and at roughly 300M parameters it can sit resident on a laptop. We already run it as a local server for skill retrieval, so this measurement reused the same server.

## Setup and integration

Nothing exotic. PDF parsing used pypdf, already present in our shared virtual environment, and embedding went over HTTP to the local server.

The embedding server starts with the following commands. It binds to port 42666 and answers on `/healthz` once ready.

```bash
bash .claude/skills/embeddinggemma/scripts/embeddinggemma_ctl.sh start
bash .claude/skills/embeddinggemma/scripts/embeddinggemma_ctl.sh status
```

When you vectorize documents, the prefix the client attaches matters. The EmbeddingGemma family expects different prefixes for documents and queries, and dropping them visibly flattens the similarity distribution.

```python
from embeddinggemma_client import embed, cosine

doc_vecs = embed(paper_heads, kind="document", dims=768)   # title: none | text: ...
q_vec = embed(research_question, kind="query", dims=768)   # task: search result | query: ...
ranked = sorted(((cosine(q_vec, v), pid) for pid, v in zip(ids, doc_vecs)), reverse=True)
```

Text extraction walks the PDF page by page while the clock runs. Screening does not need the full text, so we collect the first 2,000 characters and stop. That early exit is what actually keeps screening cheap.

```python
buf, total = [], 0
for page in PdfReader(path).pages:
    chunk = page.extract_text() or ""
    buf.append(chunk); total += len(chunk)
    if total >= 2000:      # the head is enough for screening
        break
```

Two scripts handle the extraction benchmark and the screening benchmark, writing results to JSON and a log.

```bash
python3 scripts/blog/_zotero_triage_bench_20260729.py   # download plus full-text extraction
python3 scripts/blog/_zotero_triage_embed_20260729.py   # head embedding plus query ranking
```

We installed nothing new. The PDF parser was already in the virtual environment and the embedding server was already running for another purpose, so the whole measurement finished without a fresh dependency. That is an observation in itself. The two pillars of a triage pipeline, a PDF parser and a sentence embedding model, are ordinary parts in most development environments, and what a commercial plugin sells is less those parts than the integrated experience of wiring them into the Zotero window.

## Measured results

Text extraction first. All ten papers are real arXiv PDFs totaling 298 pages.

| Item | Measured |
|---|---|
| Papers | 10 |
| Total pages | 298 |
| Total extraction time | 3.92 s |
| Extraction per paper | 0.392 s |
| Extraction throughput | 76.0 pages/s |
| Tokens per paper (estimated) | median 22,156, mean 24,379 |

The slowest was the 82-page `2607.16900` at 0.90 seconds; the 14-page `2607.20064` took 0.24 seconds. It tracks page count almost linearly. Token counts convert characters at 3.8 characters per token for English, so read them as estimates.

We also timed downloads, and nothing interesting happened there. File sizes ranged from 0.43MB to 10.41MB, yet each download took between 0.06 and 0.73 seconds. If your library is already on disk this stage disappears entirely. The network is not the bottleneck, so the rest of this discussion drops downloads and looks only at extraction and inference.

![Bar chart comparing per-paper extraction time and 1,000-paper scaling](/assets/images/zotero-ai-triage-1000-papers-results.png)

Scaling to 1,000 papers sharpens the picture. Full-text extraction alone takes 391.9 seconds, or 6.5 minutes. That is single-process, so parallelism helps, but a good chunk of the "few minutes" budget is already gone. The real wall comes next. Feeding 1,000 full texts to a language model produces 24.38M prompt tokens. Digesting that in five minutes requires a prefill throughput of 81,266 tokens per second; ten minutes needs 40,633, thirty minutes needs 13,544, and even a full hour still needs 6,772. A small model on a laptop does not reach those numbers. That is batch inference territory on a serving cluster.

The screening path sits at the opposite end. Embedding the first 2,000 characters of ten papers took 0.35 seconds in total, 0.035 seconds per paper. Encoding one query took 0.01 seconds. Scaled to 1,000 papers that is 35.0 seconds, faster than the marketing copy promises.

We checked ranking quality as well. Given the query "agent harness memory and context management for long-horizon LLM agents", the top three came out as follows.

| Rank | Cosine similarity | arXiv ID | Paper |
|---|---|---|---|
| 1 | 0.6897 | 2607.20064 | PRO-LONG (programmatic memory) |
| 2 | 0.6350 | 2607.16621 | From Memory to Skills (MSCE) |
| 3 | 0.5620 | 2607.13285 | Harness Handbook |

The three memory and harness papers directly tied to the query rose straight to the top, while `2607.13716` on runtime governance landed last at 0.4263. The spread between top and bottom is about 0.26, not enormous in absolute terms, but more than enough to decide a reading order.

The practical prescription falls out of this. Screen 1,000 papers in 35 seconds, then hand only the top 20 to full summarization, and the prompt bill drops from 24.38M tokens to roughly 0.49M. That is a factor of fifty. Required prefill throughput for a five-minute run falls to 1,625 tokens per second, which is within reach of a local small model. Same laptop, same library, two orders of magnitude apart purely from where the LLM sits in the chain.

## What this means for ThakiCloud

The result touches our two products in different ways.

**From the ai-platform side**, the full-summary path is a textbook batch inference workload. A 24.38M-token prefill behaves nothing like interactive serving. Latency can be loose, throughput has to be squeezed to the limit, and requests arrive all at once with no human waiting. Our ai-platform partitions GPU queues with Kueue on Kubernetes and serves models through vLLM, so this kind of job belongs in a separate queue from interactive endpoints and runs better as an overnight batch. Being able to run the same pipeline on-premise also matters more than it sounds when the material is internal documents or papers that cannot leave the building. For many organizations, pushing an entire library into a commercial API runs into export review long before it runs into cost.

**From the Paxis side**, the screening stage is the interesting half. Paxis is the Agent-Native Cloud control plane that runs on top of ai-platform, treating skills, tools, policies, and audit logs as first-class resources. Its skill harness has to solve, on every request, the problem of picking the right skill out of more than 960, which is structurally identical to paper triage. Many candidates, no budget to read them all, so a cheap signal narrows the field before expensive judgment is spent on the survivors. That is also why the embedding server we use for skill retrieval dropped straight into this measurement. Papers, skills, documents: only the search target changes, while the principle of separating cheap screening from expensive reading carries over intact.

Put together: Paxis owns the selection layer that makes screening cheap, and ai-platform's batch inference takes the survivors and reads them properly. With that division in place, the size of the library stops being the problem.

## Limits and counterarguments

The measurement has clear limits. Ten papers is too small a sample to represent the distribution of paper lengths, and one 82-page outlier pulled the average up. We only handled arXiv PDFs with a live text layer, so scanned documents or papers full of image-based tables will take far longer to extract. Those need OCR and layout analysis, and the moment you add them, 76 pages per second stops meaning anything.

Token counts are estimates too. They come from dividing characters by 3.8 rather than running a real tokenizer, so papers heavy with equations and tables are probably undercounted. The prefill throughput requirements inherit the same error, since they are arithmetic on those estimated tokens.

Embedding-based screening invites its own objection. The first 2,000 characters are mostly the abstract and the opening of the introduction, so a paper whose contribution lives in the back half can slip through. The narrow 0.26 spread between top and bottom scores points in the same direction. For a literature review where precision matters, treat screening as a sort order rather than a filter and let a human at least scan the titles in the lower half.

Finally, this is not a benchmark of the plugins. We did not install PapersGPT or zotero-AI-Butler and time their internals; we ran the computation they perform, on the same materials. Real plugins may well beat our naive measurement through caching, parallelism, and incremental processing.

## Wrapping up

"A thousand papers in minutes" is half true. In our measurements, ranking 1,000 papers by embedding took 35 seconds, which is faster than the marketing copy. Having a language model read those same 1,000 full texts needs 24.38M prompt tokens, and finishing in five minutes needs 81,266 tokens per second of prefill. That is not happening on a laptop.

So the question to ask when choosing a tool is not "how many papers can it process" but **"which stage does the LLM sit in"**. A tool that pushes full texts into a model gets linearly more expensive as the library grows; one that narrows the field with a cheap signal barely gets more expensive at all. What you can try today is simple. Pick ten papers from your library, embed the first 2,000 characters, and rank them against the research question you are actually working on. If the order makes sense, spend full summarization on the top twenty. Knowing in 35 seconds that the other 980 do not need to be read is the real product here.

## Sources

- [PapersGPT for Zotero](https://www.papersgpt.com/en)
- [zotero-AI-Butler (GitHub)](https://github.com/steven-jianhao-li/zotero-AI-Butler)
- [google/embeddinggemma-300m model card](https://huggingface.co/google/embeddinggemma-300m)
- [PRO-LONG, arXiv 2607.20064](https://arxiv.org/abs/2607.20064)
- [From Memory to Skills (MSCE), arXiv 2607.16621](https://arxiv.org/abs/2607.16621)
- [Harness Handbook, arXiv 2607.13285](https://arxiv.org/abs/2607.13285)
