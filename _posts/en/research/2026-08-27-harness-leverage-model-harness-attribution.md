---
title: "Model or Harness: 58% of Explainable Performance Variance Sits on the Harness Side"
seo_title: "Unattended Agent Quality Attribution: Measuring Model Tier vs. Harness Design, ThakiCloud"
seo_description: "ThakiCloud AI Research crossed 5 harness arms with 3 model tiers across 15 dependency-ordered long-horizon tasks and ran 7,200 trials. The harness main effect and its interaction with model tier account for 58.06% of explainable variance, and a cheap weak tier fitted with a gate matches the strong tier's completion rate at 94.6 to 94.9% lower cost on the quality-per-dollar frontier."
excerpt: "Run unattended long-horizon agents and the same question keeps coming back in budget reviews: buy a better model, or fix the harness around it. Recent reports all credit 'the harness' without measuring how much. A factorial design across 7,200 measured trials splits the variance and finds 58.06% of the explainable share sitting on the harness side, and a weak tier fitted with a deterministic gate matches the strong tier's completion rate at 94.6 to 94.9% lower cost."
date: 2026-08-27
last_modified_at: 2026-08-27
tags:
  - harness-attribution
  - model-tier
  - agent-harness
  - factorial-design
  - anova
  - quality-per-dollar
  - unattended-agents
  - manage-execute-audit
  - verification-gate
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/harness-leverage-model-harness-attribution/"
---
Engineers building or operating unattended long-horizon agents will recognize the question that keeps coming back in budget and architecture reviews: buy a better model, or fix the harness around it. ThakiCloud AI Research's "Harness Leverage" paper answers that question with measurement instead of intuition. Running a factorial design that crosses 5 harness arms with 3 model tiers for 7,200 trials shows that 58.06% of explainable performance variance belongs to the harness main effect and the harness-model interaction. A cheap weak tier fitted with a deterministic gate matches the strong tier's completion rate at 94.6 to 94.9% lower cost.

## Plenty of Reports Credit the Harness, None Measured It

Over the past year, reports on long-horizon agent improvements share a common trait: they credit the results to the harness wrapping the model, not the model itself. StateM reported 95.3% raw accuracy on Terminal-Bench 2.1 at roughly $15 in API usage for the final score, against a reference configuration of $574.68. The Manage-Execute-Audit (MEA) loop introduced by LongHorizon-Harness follows the same pattern. Its cross-model gains took Qwen 3.7-Plus from 51.8% to 80.7% on WeaveBench, from 69.7% to 77.2% on Terminal-Bench 2.1, and from 2.8% to 8.3% on OSWorld 2.0. Claude Opus 4.7 rose from 20.0% to 34.3% on an OSWorld 2.0 subset. EnvHarness, Prime Agent, Apodex 1.1, and Agent Lightning v1.0 each explain their own results through harness-level design as well.

The problem is that these improvements were reported, not attributed. No one decomposed where the performance variance actually comes from, measured what it costs to substitute harness design for model tier, or separated which mechanisms move completion rate from which move cost. "It's the harness" has so far been a directional claim, nothing more. This paper fills exactly those three gaps.

## 5 Harness Arms, 3 Model Tiers, 7,200 Runs

The measurement world consists of 15 dependency-ordered long-horizon tasks. Each task is a directed acyclic graph (DAG) of 10 to 18 mandatory operations plus distractor operations, and executing a mandatory operation before its prerequisite finishes produces an observable error. The step budget is 1.25 to 2 times the number of mandatory operations, and finishing every mandatory operation within budget counts as a completion.

The harness factor has 5 arms, all implemented as real control-flow code. H0 is the baseline: full-history context with no gate. H1 is a verification gate that runs a deterministic verifier after an error is observed and executes a corrective re-proposal within the same step, so the error never enters the history. H2 is a predictive gate that intercepts an action judged to fail before execution, up to 3 times, and swaps in a corrective re-proposal. H3 is an MEA ledger that uses only externalized state as context, completed operation IDs, open operations, and the last 4 errors, and checks an audit invariant at every step. H4 is memory tiering that sends only the last 6 lines of full history plus a compressed summary of the rest, and halves the post-error learning coefficient.

The model factor is 3 simulated stochastic proposers calibrated to published tier-level accuracy. No frontier model is actually called here, and the paper states this plainly as an honesty disclosure. The strong tier has single-step action validity p=0.85 with a 1,500-token context cap, the mid tier p=0.68 with 800, and the weak tier p=0.52 with 400, and post-error learning rate q of 0.45, 0.30, and 0.15 respectively. Input token pricing is $2.50/M, $0.50/M, and $0.10/M, a 25x spread. The harness arm effects, token accounting, cost, and wall time are all measured end to end on real execution. Each cell runs 15 tasks times 32 seeds for 480 trials, and the full design totals 5 x 3 x 480 = 7,200 trials.

## The Answer Is 58.06%: Most of the Explainable Variance Sits on the Harness Side

A balanced two-way analysis of variance (ANOVA) on run-level completion rate shows model tier as the larger single main effect (η² = 0.0927, 41.94% of explained sum of squares). But combine the harness main effect (η² = 0.0661, 29.90%) with the harness-tier interaction (η² = 0.0623, 28.18%) and they claim 58.06% of the explainable variance. The paper defines this share as the harness leverage share (HLS) and attaches a 95% bootstrap confidence interval of [0.5677, 0.5983].

The interaction turns out to be nearly as large as the harness main effect itself. That signature means the harness mechanism's effect changes with model strength, and a single-axis ablation misses exactly this part. The paper recommends reporting HLS alongside η² for any factorial design that crosses harness arms with models, and lays the two accounting choices side by side: 0.2990 if you count only the harness main effect, 0.5806 if you include the interaction. It lets readers see directly how the attribution choice moves the headline number. The explainable fraction itself is only 22.10%, and the remaining 77.90% is dominated by task difficulty, which means harness effects concentrate on hard tasks and the absolute level of completion rate is suite-dependent. That is why HLS has to be remeasured for every target suite.

![Share of Explainable Variance by ANOVA Source](/assets/images/posts/research/harness-leverage-model-harness-attribution/fig3_anova_share_of_explained_variance.webp)
*Model tier is the larger single main effect, but the harness main effect and the harness-tier interaction together claim 58.06% of the explainable variance, the harness leverage share. In this design, model tier is a simulated proposer calibrated to published accuracy and the harness is real control-flow code; the numbers are measured on CPU-only containers.*

## Gates Buy Completion, Ledgers Buy Tokens

Split each arm into a completion channel (change in completion rate) and a cost channel (change in tokens and cost) and a picture emerges: each mechanism does its main work through a different channel. The contrasts that matter for judgment sit in the weak tier, since the strong tier is already near saturation (H0 at 98.96%), so completion-rate contrasts there fall within the margin of error.

In the weak tier, H0's completion rate is 62.50%. H1 and H2 both reach 100.00%, and the 95% contrast interval for the +37.50pp improvement excludes zero. H3 lands at 66.87% (+4.37pp) and H4 at 66.04% (+3.54pp), with contrast intervals that cross zero, statistically indistinguishable from H0 under the independence approximation. In the strong tier, gates suppress error actions: the error-action rate drops from 0.0727 (H0) to 0.0044 (H1) and 0.0002 (H2), a 94.0% and 99.7% reduction.

The cost channel tells a different story. In the weak tier, H3 cuts tokens from 9,040.8 to 7,512.8 (−16.9%) and cost by the same ratio. The degraded-step rate, where context overload lowers the odds of a valid action, also drops from 0.6652 to 0.2839 (a relative −57.3%). Its completion-rate gain of 4.37pp is not significant. H4 is the opposite case: the last 6 lines plus summary still overshoot the weak tier's 400-token cap, pushing the degraded-step rate up to 0.8430 (from 0.6652 at H0), and halving the learning coefficient leaves the error-action rate essentially unchanged from H0 (0.2803 vs. 0.2805). H4 fixes the weak tier on neither channel. Gates buy completion at a token premium: cost rises 2.3% for H1 and 6.6% for H2 in the weak tier, and 8.0% for H1 and 9.1% for H2 in the strong tier. No single arm dominates both channels at once in any cell, which is exactly why combining a gate with a ledger is the natural next step.

![Completion Rate by Harness Arm and Model Tier](/assets/images/posts/research/harness-leverage-model-harness-attribution/fig1_completion_by_arm_and_tier.webp)
*The deterministic verification gate (H1) and the predictive gate (H2) raise weak-tier completion rate from 62.50% to 100.00%, while the MEA ledger (H3) and memory tiering (H4) show no statistically meaningful difference from baseline. In this design, model tier is a simulated proposer calibrated to published accuracy and the harness is real control-flow code; the numbers are measured on CPU-only containers.*

## Under a Cent per Run: the Quality-per-Dollar Frontier

Even though the price spread is 25x and the completion-rate range is only 0.625 to 1.000, completions per $1,000 span a 19.7x range, from 1.081 (H1, weak tier) down to 0.055 (H2, strong tier). Across the 15 cells, tier draws the cost band and the harness sets the quality inside it.

Plotting cross-tier (arm, tier) pairs whose completion rates sit within 1pp of each other on a substitution frontier shows that the cheaper side of the top 5 pairs is every time a gated weak tier. Measured savings run 94.6 to 94.9%, roughly 20x cheaper. Within the same arm, the strong-to-weak cost ratio is 19.4x for H1 and 18.4x for H0, since the dominant cost axis is tier substitution. The cheapest path to matched completion is a gated weak tier. What the MEA ledger substitutes for is tokens, and in the weak tier that trade costs −16.9% in cost for +4.37pp in completion. The direction matches StateM's benchmark-level substitution of $15 vs. $574.68 (38.3x). There is now a measured number on the agent-mechanism side too.

![Quality-per-Dollar Frontier: All 15 Measured Cells](/assets/images/posts/research/harness-leverage-model-harness-attribution/fig2_quality_per_dollar_frontier.webp)
Measured 15 (arm, tier) cells form three cost bands by tier, and gated weak-tier cells reach 100% completion at under a cent per run, roughly 20x cheaper than their strong-tier counterparts. In this design, model tier is a simulated proposer calibrated to published accuracy and the harness is real control-flow code; the numbers are measured on CPU-only containers.*

## What This Leaves for the Company, Society, and Science

For ThakiCloud, this gives the Paxis execution-layer positioning empirical footing. Where to spend money becomes a measurable question: which harness variant captures most of the agent-quality gain per dollar, and at what cost a harness upgrade substitutes for a model-tier upgrade. This design's answer points toward investing in harness design over model spend.

Socially, this lowers the barrier to entry for unattended agent automation. A cheap harness upgrade that substitutes for an expensive frontier model tier lets small organizations reach comparable task quality for a fraction of the API cost, and energy spend falls with it.

Scientifically, this is the first quantitative model of model-versus-harness attribution for agent quality. It measures the direction that recent reports have been pointing, that the harness rather than the model determines agent quality, and turns it into a reusable benchmark: the harness leverage share. The factorial design shows in numbers exactly what a single-axis ablation misses: the interaction term.

## What This Measurement Does Not Answer

Because model tier is a simulated proposer, the absolute gap between tiers comes from the calibration itself. The harness main effect, the interaction, and every cost number are measured values, but the assumption of how strong a real frontier model actually is stays baked into the design.

The measurement world is a single family of dependency-ordered operations. Results could differ on open-ended or state-heavy suites. In particular, on state-heavy suites a ledger could work through the completion channel too, and the channel mix is suite-dependent. The gate success constants (0.95, 0.90), the 3-attempt-per-step cap, W=6, and the 0.5x learning coefficient are all design choices, not tuned hyperparameters.

The gates in this design are deterministic and cost zero LLM calls. So the 94.6 to 94.9% substitution savings is an upper bound on what a weak tier with a realistic gate can achieve against a strong tier. A real verification gate is itself a model call, so it spends its own tokens and its reliability degrades with tier. Wall time excludes LLM network latency, and the design is structurally balanced. The reported confidence intervals rely on an independence approximation, and seed-matched paired contrasts could narrow them further. What the residual in this measurement shows above all is that most of the variance sits in task difficulty, not in the factor effects.

---

Paper detail page: https://thakicloud.com/tech-blog/en/research/harness-leverage-model-harness-attribution/
