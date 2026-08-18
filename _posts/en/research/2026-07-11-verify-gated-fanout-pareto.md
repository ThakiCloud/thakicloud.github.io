---
title: "Less Verification Is Safer: Measuring the Cost-Quality Curve of Multi-Agent Verification Gates"
excerpt: "The principle that every fan-out should close with adversarial verification is widely accepted, but how much verifier tier and how many skeptics to use has mostly been set by convention rather than measurement. We present a study that tests this assumption with 12 findings and 180 real API calls."
tags: [multi-agent, llm-orchestration, adversarial-verification, model-routing, cost-optimization, hallucination-detection, ai-agents, skill-orchestration]
date: 2026-07-11
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/verify-gated-fanout-pareto/"
categories: [research]
author_profile: true
toc: true
audiobook: "https://drive.google.com/file/d/1KtL3fNDCDT1c0OZyxlMc8E0SJ5FBummf/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you operate or are considering adopting a fan-out pipeline where multiple agents run in parallel and their results get aggregated, you have probably picked a verifier model and a headcount for the verification step by convention at some point. This post introduces a study that measures what that convention actually costs and what safety it actually buys. The short answer: throwing more expensive models and more of them at verification does not always make the pipeline safer.

![Illustration of the core idea of Less Verification Is Safer: Measuring the Cost-Quality Curve of Multi-Agent Verification Gates](/assets/images/verify-gated-fanout-pareto-hero.webp)
*A visual metaphor for the article's key idea.*

## The problem: a verification principle existed, but no measurement did

In multi-agent systems where several worker agents each produce their own results, there is always a risk that a low-cost worker model will produce a plausible-sounding but ungrounded finding. To guard against this, practitioners have settled on the principle that "every fan-out closes with adversarial verification." Under this scheme, several independent skeptic agents attempt to refute each finding a worker produces, and once refutations cross a defined threshold, code automatically discards that finding.

The problem is that two variables inside this principle, the tier of the verifier model assigned as skeptic and how many skeptics to assign, along with which majority rule to use, have mostly been fixed by convention rather than measurement. The assumption that a more expensive verifier model is safer, and that more skeptics are safer, sounds intuitively plausible, but no prior study had confirmed this assumption on a real multi-agent harness against a benchmark with known ground truth before this paper.


## Core contribution: reconstructing 27 configurations from 12 findings and 180 real API calls

The researchers built a controlled benchmark on top of a real production-grade multi-agent orchestration harness. They prepared 12 findings total, 6 genuinely valid and 6 deliberately fabricated, and collected 5 independent skeptic verdicts per finding for each of three verifier tiers, Haiku, Sonnet, and Opus. The actual API calls collected this way numbered 180, with zero failures, at a total cost of $96.91. The key methodological move here is that this single draw was sliced post-hoc: all 27 configurations combining skeptic headcount N (1/3/5) and three threshold rules, majority, unanimous, and strict veto, were reconstructed deterministically without any additional API calls.

![Cost vs. Hallucination Survival Rate by Tier and Breadth]({{ '/assets/images/posts/research/verify-gated-fanout-pareto/fig_pareto_cost_quality.webp' | relative_url }})
*Measured cost versus hallucination survival rate broken down by tier and headcount. Except for Opus configurations using majority or unanimous rules at 3-5 skeptics, every verified configuration filtered out hallucinations completely (0.0), while the unverified baseline let every finding pass through (1.0). The single-Haiku configuration ($3.46) was the only Pareto-optimal point.*

The first thing confirmed was that exactly one of the 27 configurations was Pareto-optimal, and it was the cheapest one. Verifying all 12 findings with a single Haiku skeptic cost $3.46, and this configuration simultaneously achieved a hallucination survival rate of 0.0 and a true-finding survival rate of 1.0. Every one of the remaining 26 configurations fell short of this configuration on at least one of the three axes: cost, hallucination suppression, and true-finding preservation.

The second notable result is that Opus was never Pareto-optimal, not even once. A single Opus skeptic matched the quality of a single Sonnet skeptic exactly while costing 1.68 times as much, and Opus with 5 skeptics under the majority rule cost 15.66 times more than the optimal point while its hallucination survival rate actually got worse, at 0.167. The practitioner intuition that raising the verifier tier buys more safety did not hold up on this benchmark.

![Cost vs. True-Finding Survival Rate by Tier]({{ '/assets/images/posts/research/verify-gated-fanout-pareto/fig_cost_true_survival.webp' | relative_url }})
*Measured true-finding survival rate by tier. Sonnet and Opus never lost a single true finding across any headcount or rule combination (1.0), but Haiku under the strict veto rule at 3 and 5 skeptics incorrectly discarded one true finding due to a skeptic misjudgment (0.833).*

The most interesting finding was that increasing skeptic headcount is not always safer. Under the Opus/majority combination, raising the skeptic count from 3 to 5 actually worsened the hallucination survival rate, from 0.0 to 0.167. Tracing the cause revealed that for one specific fabricated finding, only 2 out of the 5 skeptics correctly refuted it, a 40 percent accuracy rate. In the 3-skeptic slice, the same 2 correct votes represented 2/3, or 67 percent, clearing the majority threshold and discarding that finding. In the 5-skeptic slice, the same 2 correct votes represented only 2/5, or 40 percent, falling short of the majority and letting the finding survive. This is a form of vote dilution structurally similar to Condorcet's paradox, in which plurality-style majority rules become structurally fragile on hard items where individual skeptic accuracy falls below 50 percent.

![Non-Monotonicity: Adding More Skeptics Can Harm Verification Safety]({{ '/assets/images/posts/research/verify-gated-fanout-pareto/fig_nonmonotonicity.webp' | relative_url }})
*An analysis chart showing the non-monotonic effect in which adding more skeptics actually reduces verification safety. Under the Opus/majority rule, hallucination survival rate was 0.0 at N=1 but rose to 0.167 at N=5, consistent with a Condorcet-style dilution effect where majority aggregation structurally loses safety once per-item individual skeptic accuracy drops below 50 percent.*

This result also reveals the importance of rule choice. "Unanimous" sounds like the most cautious rule by name, but in practice it was the most fragile rule, recording a hallucination survival rate of 0.167 at both N=3 and N=5 under the Opus tier. In contrast, the strict veto rule, which discards a finding immediately if even a single skeptic refutes it, was the only rule that achieved a hallucination survival rate of 0 across every tier and every headcount configuration. This rule was not without its own cost, however: at the low-cost Haiku tier, noise-driven skeptic misjudgments caused a small number of cases where a true finding was incorrectly discarded (true-finding survival rate of 0.833).

## Contribution to the company, society, and science

ThakiCloud has already operated under the house rule that "fan-out closes with verification," but the optimal combination of verifier tier, skeptic headcount, and majority rule had only ever existed as a descriptive principle, never as something actually measured. This study provides a Pareto curve obtained from a real production harness and a deterministic aggregation script, giving a cost-based basis for optimizing the verification gate settings of multi-agent workflows already in operation, such as skill review, research fan-out, and the paper pipeline.

More broadly, this study demonstrates that even small teams without a generous verification budget can build a reliable agent audit pipeline at low cost. It is also the first study to quantify, on a controlled benchmark with known ground truth, how verifier tier, skeptic count, and majority threshold affect hallucination survival rate in a fan-out style multi-agent pipeline. It has taken adversarial verification practice, which had previously remained at the level of a stated principle, and elevated it to a measurable curve.


## Limitations

The researchers are explicit about the limits of these results. The benchmark itself is a small-scale experiment based on 12 findings and a single draw, so percentages move in coarse sixths. In particular, the N=3 and N=5 conditions are not separately resampled independent trials but were constructed by slicing the same 5-draw set post-hoc, meaning a single outlier can affect multiple cells at once, and for this reason no statistical significance testing was performed given the sample size. Only three tiers within the Claude family, Haiku, Sonnet, and Opus, were tested, so there is no basis for assuming this tier ordering transfers to other model families, and the cost figures reflect API pricing as of July 10, 2026, so which configuration dominates could change if prices shift. The researchers note that while the Condorcet dilution mechanism itself is mathematically sound, this small-scale benchmark alone cannot answer how often hard items fall into the sub-50-percent skeptic accuracy regime in real operating conditions, and they propose a larger-scale seeded benchmark with independent resampling per cell as the next step.

Full paper details are available on the Hugging Face dataset page: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-11-verify-gated-fanout-pareto](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-11-verify-gated-fanout-pareto)
