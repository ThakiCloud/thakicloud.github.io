---
title: "What Should You Actually Measure? Human-KO vs EXAONE, Side by Side"
excerpt: "Exam scores and conversational register are different subjects. We put our Human-KO 27B next to EXAONE 4.5 33B on identical questions under identical conditions — and report both axes exactly as measured."
seo_title: "Qwen3.8-27B-Human-KO vs EXAONE-4.5-33B: Measured Comparison"
seo_description: "We compared the open-weights Human-KO 27B against EXAONE-4.5-33B on 2,000 item-paired KMMLU questions, 500 HAE-RAE questions, and free-generation style distribution. Which model wins depends on the axis."
date: 2026-09-01
published: true
categories:
  - llmops
tags:
  - korean
  - benchmark
  - open-weights
  - human-ko
  - exaone
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/humanko-27b-vs-exaone/"
---

The most common question about the [Human-KO 27B we released](https://thakicloud.com/tech-blog/en/llmops/humanko-27b-release/) is a simple one: "So is it better than other Korean models?" Today we answer with numbers. The short version: which model wins depends on **what you measure**.

## Plain terms

No company hires customer-support staff by college entrance exam scores. Knowledge tests and conversational manner are different subjects, and a good recruiter reads the report card that matches the seat. Model comparison works the same way. This article lays two report cards side by side. One is a knowledge exam (KMMLU and HAE-RAE). The other is a register test: what each model sounds like when you give it no instructions at all. This report-card picture carries through the article.

## How we measured

Three models stood under identical conditions: our Human-KO 27B, its base Qwen3.8-27B, and LG AI Research's EXAONE 4.5 33B. EXAONE was used for evaluation purposes as its research license permits.

For the knowledge axis we drew 2,000 KMMLU and 500 HAE-RAE questions with a fixed seed. **All three models answered the exact same items**, so score gaps cannot be explained by question luck. For the register axis, each model answered 200 questions freely with no system prompt, and we counted bullet-list answers and answer lengths. No judge model involved; just counting.

## The knowledge report card

| | Human-KO 27B | Base Qwen 27B | EXAONE 4.5 33B |
|---|---|---|---|
| KMMLU (n=2,000) | 64.2% | 63.7% | 55.9% |
| HAE-RAE (n=500) | 57.4% | 58.6% | 49.5% |

This surprised us too. Under these conditions our model scored significantly higher than EXAONE on both axes — 8.4pp on KMMLU and 7.9pp on HAE-RAE, both statistically clear. But the result carries an important qualifier: we ran all three models with thinking mode disabled and forced single-letter answers. EXAONE 4.5 is designed around its reasoning mode, so this protocol takes away its main weapon. That is also why these numbers differ from LG's published scores.

In plain terms: on a test where the model must answer immediately without time to think, ours came out ahead. The long-deliberation condition that favors EXAONE is not measured in this article.

The gap between our model and its base was statistically indistinguishable on both axes. The style surgery did not cut into knowledge, which was the first thing we wanted to confirm from this comparison.

## The register report card

Same 200 questions, no instructions. That condition matters: prompt any model with "answer briefly" and it will. What we measure here is the **default**.

| | Human-KO 27B | Base Qwen 27B | EXAONE 4.5 33B |
|---|---|---|---|
| Answers formatted as bullet lists | 2.0% | 97.5% | 94.0% |
| Median answer length | 220 chars | 1,326 chars | 1,539 chars |

EXAONE shows the same habit as base Qwen: nine answers out of ten arrive as bullet lists, at around fifteen hundred characters. Among the three, only ours defaults to a human register. This is not a capability gap — it is a training-objective gap. The other two were simply not built for it.

Answer length is serving cost. A model that answers the same question seven times shorter runs that much cheaper wherever billing is per token.

## So which one should you use

If the seat needs short answers, fast, in a human register — support desks, internal chatbots, messenger-style products — this measurement favors our model. If the seat needs long, deep reasoning, do not judge by this article's numbers. We did not measure that condition, and EXAONE with reasoning enabled may be a different model. Read the report card that matches the seat; that one sentence is the conclusion.

## What not to trust yet

The limits, stated plainly. The knowledge-axis sample cannot detect a 1pp-level difference. "Good" on the register axis is use-case dependent — where long structured documents are the job, bullets and length are the right answer. EXAONE was measured with thinking mode off and answers forced to a single letter; 13 of its HAE-RAE responses broke that format and were excluded from scoring (n=487). EXAONE's scores with reasoning enabled may be higher than these numbers. LG's official figures are not directly comparable because the protocols differ, and the model sizes are not equal (27B vs 33B).

## References

- Human-KO model: <https://huggingface.co/ThakiCloud/Qwen3.8-27B-Human-KO>
- Release article: <https://thakicloud.com/tech-blog/en/llmops/humanko-27b-release/>
- EXAONE 4.5: <https://huggingface.co/LGAI-EXAONE/EXAONE-4.5-33B>
