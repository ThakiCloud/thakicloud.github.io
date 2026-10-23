---
title: "Which Rewrite Should You Pick? Releasing Two EditRank Models"
excerpt: "When one document has been rewritten several ways, which version will an AI answer engine rank higher as a source? EditRank is a small model that ranks those rewrites. We are releasing a 0.6B and a 4B version as research previews, along with how often they pick a rewrite that changes the facts."
seo_title: "EditRank-0.6B and EditRank-Multidomain-4B: Edit-Ranking Models - ThakiCloud"
seo_description: "ThakiCloud released EditRank, a Research Preview reranker that ranks candidate rewrites of one document for one query. The 0.6B model beat BM25 on product pages, and the 4B model showed higher utility and a lower fact-violation rate than the 0.6B on technical documentation. Covers the simulated-engine results and the limitations."
date: 2026-10-24
last_modified_at: 2026-10-24
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cube"
tags:
  - editrank
  - reranker
  - generative-engine-optimization
  - qwen3-reranker
  - listwise-ranking
  - research-preview
  - open-weight
  - paxis
categories:
  - owm
canonical_url: "https://thakicloud.com/tech-blog/en/owm/editrank-open/"
header:
  teaser: /assets/images/editrank-open-chart-en.png
---

This post is for people who maintain product descriptions or technical documentation and wonder how answer-style search engines treat those pages. When one document has been rewritten several ways, we are releasing a model that picks the version an answer engine would rank higher as a source. It was trained to pick versions that leave every fact of the original unchanged.

The short version: it ranks rewrites reasonably well, but it cannot check facts. That makes it a research model that must not be used without human review.

ThakiCloud is releasing it in two sizes, a light 0.6B and a 4B trained on several domains. Both are research previews, not production models.

## In plain terms

Think of a resume coach. Say the same work history has been written up as five different resumes. One version polishes the sentences, and another mirrors the wording of the job posting. One quietly adds a project the applicant never did. The coach picks the version most likely to get through screening.

EditRank is that coach. The query is the job posting, the document is the resume, and the answer engine is the screener. The coach was taught not to pick resumes with inflated experience. But the coach cannot look up the applicant's real history. So it does sometimes pick an inflated resume as the best one. The most important number in this post is how often that happens.

## What the model is

The input is a search query, an original document and a revised document. The model outputs one score: the `yes` logit minus the `no` logit. A higher score means the model expects the revised version to rank higher than the original in the answer engine's source list. Score every candidate and take the highest. Scores are only comparable within one query.

[EditRank-0.6B](https://huggingface.co/ThakiCloud/EditRank-0.6B) is the light model, evaluated on product pages. [EditRank-Multidomain-4B](https://huggingface.co/ThakiCloud/EditRank-Multidomain-4B) was trained on product pages, game descriptions and technical documentation together. Both are released as Research Preview.

Both models are built on Qwen3-Reranker. The 0.6B is a full fine-tune of `Qwen/Qwen3-Reranker-0.6B`. The 4B adds LoRA to `Qwen/Qwen3-Reranker-4B` and merges it into the weights. We covered the base models in our [Qwen3 embedding and reranker guide](/tech-blog/en/owm/qwen3-embedding-reranker-complete-guide-en/). The license is Apache-2.0 and the language is English.

The training objective is a listwise cross-entropy that targets the top-1 candidate across each query's whole candidate set. Candidates that change facts get the lowest utility, so they never become the training target. The 4B adds one more thing. The unchanged original is always among the candidates, so the model learns to keep it when it is best. In resume terms, "don't change anything, send the original" is one of the coach's options.

Candidate rewrites and ranking labels were produced with an in-house deployment of the open-weight Qwen3.8-27B. No outputs of commercial LLM APIs were used. Training and evaluation data are not released.

## How we measured

These results do not come from live AI search products. They come from a simulated setup where two fixed open-weight answer engines rank sources. One is a Qwen3.8-27B engine from the same family that produced the training labels. The other is a Gemma-4-31B engine that produced no training label. Decisions were made on the independent Gemma engine.

Utility is how many positions, on average, the selected candidate moved up the source ranking compared with the original. Keeping the original scores 0. Picking a candidate that changes facts receives a penalty below the worst candidate. Comparisons and thresholds were fixed before training, and each model was trained once without hyperparameter search.

## EditRank-0.6B: beating BM25 on product pages

The 0.6B was evaluated on 624 Amazon ESCI queries not used in training. Its utility on the Gemma engine was 0.48, above BM25 at 0.21. The paired bootstrap difference is +0.27, with a 95% confidence interval from 0.16 to 0.39. What makes this number meaningful is that an engine which produced no training labels confirmed it.

Using the base model as is, with a relevance prompt, gave a Gemma utility of 0.05. Simply taking an off-the-shelf reranker does not solve this task. Always applying one fixed rewrite strategy scored 0.34, and EditRank's margin over it was only barely significant. An oracle that knows the best candidate in advance scores 1.03, so there is still a long way to go.

We repeat what the model card states plainly. The model was not shown to be better than an earlier run of the same family. On the Gemma engine the difference is +0.02 and the confidence interval crosses 0. We also make no claim that the listwise objective beats the earlier one.

## EditRank-Multidomain-4B: one step further on technical docs

The main evaluation of the 4B is 184 technical-documentation groups drawn from the official Kubernetes and Python docs. Other versions, translations and sibling pages of the same topic were kept entirely out of training.

![Utility and fact-violating top-1 rate of EditRank-Multidomain-4B, EditRank-0.6B, the fixed best strategy and BM25 on 184 documentation groups](/assets/images/editrank-open-chart-en.png)
*The two axes of the documentation evaluation. Higher is better on the left, lower is better on the right.*

| Method | Utility (Gemma) | Utility (Qwen) | Unsafe top-1 | Over-edit loss (Gemma) | Original kept |
|---|---|---|---|---|---|
| **EditRank-Multidomain-4B** | **2.010** | **2.273** | **10.3%** | **0.175** | 8.2% |
| EditRank-0.6B | 1.782 | 2.107 | 17.9% | 0.316 | 7.6% |
| Fixed best strategy | 1.743 | 2.010 | 23.4% | 0.358 | 0% |
| BM25 | 1.160 | 1.396 | 16.3% | 0.322 | 0% |
| Keep the original | 0 | 0 | 0% | 0 | 100% |

On the Gemma engine the 4B scored 0.23 higher utility than the 0.6B, with a 95% confidence interval from +0.07 to +0.42. On the Qwen engine the difference was +0.17, but the interval includes 0, so it is not significant. Over-edit loss is the average utility lost when the chosen rewrite is worse than the original. It was significantly lower than the 0.6B on both engines.

The fact-violating top-1 rate was 10.3%, down from 17.9% for the 0.6B. A stricter judge that checks only numbers and quotes flagged 4.9%, versus 6.5% for the 0.6B. The coach picks inflated resumes less often. It has not stopped doing it.

On the 624 product-page queries, the 4B's Gemma utility was 0.47, on par with the 0.6B at 0.48. The difference is -0.01, with an interval from -0.09 to +0.08. These queries were already used in earlier decisions, so this is a development comparison rather than an independent test. If you only deal with product pages, the 0.6B is enough.

There is no independent evaluation for game descriptions. A 37-group exploratory set shares documents with training, so it is not used for any claim. Generalization to video games is unverified.

## This model is not a fact checker

Both model cards open with the same warning. The bundled examples show why. In the 0.6B example, the original scored +3.63, a rewrite inventing "waterproof" and "best boot of 2026" scored +3.50, and a faithful rewrite scored +3.13. The invented version ranked above the faithful one.

The 4B example is a Kubernetes page on memory limits. The faithful rewrite came first at +3.94. But a rewrite that invents a version number, a latency and a statistic scored +3.75, above the original at +3.31. The inflated resume scored higher than the real one.

The automated judge that measures the violation rate is imperfect too. The 0.6B card reports a 60-sample audit with flag precision 0.63 and at least 6.7% of unflagged cases missed. The true rate could be off in either direction.

The decision to keep the original is still weak. Among product groups where the original is strictly the best candidate (25 groups), the 4B kept it only 20% of the time. The 0.6B kept it 32% of the time. The documentation test set has only 2 such groups, so it barely tests this decision.

## Limitations to know before use

The biggest limitation is that every result comes from simulated engines. There is no evidence of increased exposure in live products such as ChatGPT, Gemini, Perplexity or Google AI Overviews. Do not read the documentation utility gain as a traffic gain. Answer engines change, and rankings learned against these engines may not transfer to others.

The documentation queries are not real user queries. They are synthetic queries that Qwen3.8-27B generated from documentation sections. Documents are clipped at 1,500 characters, the original at 600, and inputs are truncated at 1,280 tokens. Long documents, languages other than English, news, and SaaS or marketing content were not tested.

So both cards require the same usage. Do not automatically publish or apply the edit the model picks. Every selected edit needs external fact verification and human approval. Even with a coach's pick, the applicant still checks the resume against their real history before sending it.

## Try it yourself

Each repository's `example_inference.py` contains the exact prompt format used in evaluation. Below is a shortened version of the 4B example. Include the original among the candidates, and keep it if it ranks first.

```python
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

MODEL_ID = "ThakiCloud/EditRank-Multidomain-4B"  # or "ThakiCloud/EditRank-0.6B"
PREFIX = ('<|im_start|>system\nJudge whether the Document meets the requirements based on the Query and the Instruct provided. '
          'Note that the answer can only be "yes" or "no".<|im_end|>\n<|im_start|>user\n')
SUFFIX = "<|im_end|>\n<|im_start|>assistant\n<think>\n\n</think>\n\n"
EDIT_INSTR = ("Given a search query, an original document and a revised version of it, judge whether the revised version would be "
              "selected and ranked higher by an AI answer engine for this query than the original, while keeping every fact of "
              "the original unchanged.")

def clip(s, n=1500):
    return s if len(s) <= n else s[:n] + " ..."

def build(query, original, revised):
    doc = f"ORIGINAL (excerpt): {clip(original, 600)}\n\nREVISED: {clip(revised)}"
    return f"{PREFIX}<Instruct>: {EDIT_INSTR}\n<Query>: {query}\n<Document>: {doc}{SUFFIX}"

@torch.no_grad()
def score(model, tok, query, original, candidates, max_len=1280):
    yes_id, no_id = tok.convert_tokens_to_ids("yes"), tok.convert_tokens_to_ids("no")
    enc = tok([build(query, original, c) for c in candidates], padding=True, truncation=True,
              max_length=max_len, return_tensors="pt").to(model.device)
    logits = model(**enc).logits[:, -1, :]
    return (logits[:, yes_id].float() - logits[:, no_id].float()).tolist()

tok = AutoTokenizer.from_pretrained(MODEL_ID, padding_side="left")
model = AutoModelForCausalLM.from_pretrained(MODEL_ID, dtype=torch.bfloat16, device_map="cuda").eval()
```

The candidate with the highest value from `score()` is the model's pick. Whether that pick kept the facts must be decided by a separate verification step.

The inference cost in the 4B card is also worth noting. Running 624 product groups of 10 candidates each in bf16 on one B200 gave a per-group latency of p50 168 ms and p95 257 ms. It processed about 56 candidates per second with a peak memory of 12.5 GiB.

## Where it fits

The first fit is research. For anyone studying how document edits affect source ranking in conversational search, it is a reproducible baseline. Both cards record the base model revision, weight hashes and pre-registered metrics in `eval_manifest.json`.

The second is document improvement workflows with human review. It can order several rewrites before a person looks at them. Even then, the top candidate is only a suggestion, and fact verification and approval happen outside the model.

Paxis, ThakiCloud's work automation platform, is designed to pass each work step through policy gates and human approval. A model like EditRank could be thought of as one step inside such a structure, narrowing down candidates. However, EditRank is not integrated into any product yet. This post is not selling that possibility.

## What we released

Each repository contains the weights, configuration, tokenizer, model card, `eval_manifest.json` and an example script. [EditRank-0.6B](https://huggingface.co/ThakiCloud/EditRank-0.6B) is the light model evaluated on product pages. [EditRank-Multidomain-4B](https://huggingface.co/ThakiCloud/EditRank-Multidomain-4B) is the model evaluated on technical documentation as well. Data sources, licenses and citations are detailed in each card.

Before release, the files in both repositories were downloaded separately into an empty cache and compared against the original training checkpoints. Weight hashes and tensors matched, and the top-1 selections on the evaluation queries were all identical.

EditRank does not rewrite documents for you. It suggests an order among rewrites that already exist. Even a good resume coach cannot vouch for the applicant's history. The right way to use this model is a division of labor: the model handles the ranking, and people and verification tools protect the facts.

*Source: pre-registered evaluation results published in the [EditRank-0.6B](https://huggingface.co/ThakiCloud/EditRank-0.6B) and [EditRank-Multidomain-4B](https://huggingface.co/ThakiCloud/EditRank-Multidomain-4B) model cards.*
