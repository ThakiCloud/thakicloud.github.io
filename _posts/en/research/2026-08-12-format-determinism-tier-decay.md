---
title: "There Were Only Five Rules. Why Did Thirty-Three Outputs All Come Out Different?"
seo_title: "Format Freedom and Model Tier: A Cost Model for Code-Owned Validation"
seo_description: "We introduce a paper arguing that format freedom, not rule count, is the real axis behind structured-output failure. It covers a code-owns-the-format validation pattern, a cost model for when it beats tier escalation, and an experiment designed to test it."
excerpt: "Thirty-three workers received the same three-rule instruction and returned the same field in five different shapes. This failure cannot be explained by rule count. We introduce a paper that extracts a new axis, format freedom, and a cost model for code-owned validation from it."
date: 2026-08-12
tags:
  - structured-output
  - format-compliance
  - llm-agents
  - cost-model
  - batch-pipeline
  - instruction-following
categories:
  - research
author_profile: true
toc: true
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/research/format-determinism-tier-decay/
---

If you have a batch pipeline that hands structured output to a low-cost model tier, watched the output format keep drifting, and settled on escalating to a higher tier as your default fix, this paper is going to make you reconsider that call. Its core claim is simple: before concluding that format drift comes from insufficient model grade, you first have to separate whether the failure comes from too many rules, or from handing the format itself to the model in the first place. If it is the latter, letting code own the format structurally beats escalating to a pricier tier on cost.

## An Incident With Only Five Rules

The paper's starting point is an actual incident on a Slack-integrated news-digest pipeline the authors run themselves. Thirty-three workers, all using the same mid-tier model, ran concurrently, and every one of them received the identical instruction, short and fixed at three to five rules: fill the `quality_gate` field, fill the `status` field, and return only a single line. When all 33 outputs were opened up afterward, structural inconsistency showed up along four axes at once. The `quality_gate` field, which should have been a single boolean, scattered into five different shapes: the string `"passed"`, Python/JSON `True`, a nested object holding the verdict inside it, the number `1`, and empty values. The `status` field, meant to mean "done," came back as at least four different strings, `ok`, `done`, `processed`, `completed`, mixed together as if they all meant the same thing. At least one worker's hand-written JSON string failed to parse at all due to an escaping error, and another prepended explanatory prose despite an explicit instruction to return only one line.

What makes this incident interesting is that rule count cannot explain it. The dominant explanatory frame in recent instruction-following-degradation research is that as instructions pile up, they start conflicting with each other and compliance collapses, and in one benchmark that stacked 24 instructions, compliance did in fact drop from 96% to 20%. But this incident's rule count was small, three to five, and it never grew. "Emit a single boolean" is a lone requirement with no particular reason to conflict with anything else. And yet across 33 independent calls, the same signal got encoded in five different ways. The authors read this not as rule conflict but as a problem of unregulated freedom left in the output space itself. "Emit a boolean" placed no constraint whatsoever on what surface form that value should take, and the model was not violating the instruction no matter which form it picked, every single time.

## Rule Count and Format Freedom: Two Different Axes

![Three points on the format-freedom axis](/assets/images/posts/research/format-determinism-tier-decay/fig-taxonomy-axis.png)
*A conceptual diagram splitting how much control the model holds over surface encoding into three points. This visualizes the paper's proposed taxonomy, not a measurement.*

This is where the paper's first contribution appears. Research on instruction-compliance degradation so far has largely moved along a single axis: how many rules have piled up. The authors add a separate axis: who owns the format. This axis has three points. First, a free-prose point where the model receives only natural-language instructions and decides the surface form itself. This is exactly where the incident above happened, and a case where a math benchmark showed 85% task correctness alongside 0% output-format correctness at the same time illustrates the danger of this point. Second, a point where a grammar or schema mask is applied at decode time. Compliance rises reliably, but not for free: compliance, schema coverage, and generation quality trade off against each other differently across frameworks, and output can be grammatically flawless while still being semantically wrong, pointing at something that does not exist in the actual environment. There is also the limitation that the schema's own key names act as yet another natural-language instruction channel, so different models respond to them differently. Third, the point this paper proposes: the model emits content only, and serialization is entirely owned by deterministic code outside the model.

Separating these two axes clarifies why the incident could not be explained by rule count. The incident happened at the free-prose point, and with a rule count that was small and fixed. Neither the instruction-conflict theory nor the finite-progress-tracking-capacity theory fully captures this combination. That said, the authors are careful about the standing of this reading: it is a plausible interpretation of one incident, not a proven causal mechanism, and they note it is not mutually exclusive with the instruction-conflict theory.

## A Pattern for Letting Code Own the Format, and When It Is Cheaper

The second contribution is a reusable design pattern. It has five parts: a worker contract in which the model emits only semantic content, such as raw text or short labels, and never produces the final serialization; enum normalization, where code maps values into a closed set and triggers a re-dispatch when mapping fails; code-owned serialization, where a standard serializer renders the JSON or delimited format; a deterministic quality gate, where requirements like "return only one line" are checked by code with a regex after generation; and targeted re-dispatch, where only failed items get re-sent at the same tier. The core of this pattern is not asking the model more insistently to follow the format constraint, but removing that responsibility from what the model has to do in the first place.

![Cost comparison between strategy E and strategy V](/assets/images/posts/research/format-determinism-tier-decay/fig-cost-comparison.png)
*A comparison of expected per-item cost between tier escalation (strategy E) and code-owned validation with re-dispatch (strategy V). This is not measured data; the curve is calculated directly from the paper's equations.*

Here the paper works out the cost formula. Let p_cheap be the probability that a free-prose call at the cheap tier perfectly satisfies the format contract. Then the expected per-item cost of the strategy that escalates to a pricier tier on failure (strategy E) is the cheap-call cost plus the pricier-call cost weighted by the failure probability. This carries over a structural fact from existing LLM-cascade theory: the cheap call is a cost you have to pay anyway just to determine whether escalation is needed. Strategy V, by contrast, code-owned validation followed by re-dispatch at the same tier, has a validator cost that is close to zero, essentially a string operation, so all it needs is p'_cheap, the success probability of the content-only call on re-dispatch. Placing the two strategies side by side, strategy V becomes cheaper exactly when the additional cheap-tier spend from re-dispatch is smaller than the pricier-tier spend from escalation. Given how commonly the cost multiple between tiers runs 3x to 5x or more in practice, this inequality tips fairly easily toward strategy V unless the baseline format-compliance rate is already close to 1. Conversely, if format failures are rare to begin with, the expected cost of escalation itself shrinks, and the difference between the two strategies stops mattering.

The paper also explicitly rules out a tempting third option: escalating to a higher-tier model and having that model check its own format. This is no better on cost than strategy E, and more fundamentally, it runs into existing research showing that an LLM judge systematically favors output it generated itself. Even with a structured, multi-dimensional evaluation protocol, this bias only shrinks by an average of 31.5%; it does not disappear. So the authors insist the validator has to be code, and that this property does not resolve itself just because the model gets better.

## An Experiment Design That Turns an Untested Claim Into a Testable One

![Design of the 3x3 factorial measurement protocol](/assets/images/posts/research/format-determinism-tier-decay/fig-protocol-design.png)
*A 9-cell experiment design crossing three model tiers (cheap, mid, premium) with three format-freedom conditions (free prose, schema hints, code-owned validation). The paper proposes this design but does not run it directly.*

The third contribution is an experimental protocol for testing all of these claims. Holding rule count fixed at three to five, similar to the incident, the design crosses three model tiers with three format-freedom conditions to make nine cells, and repeats each cell at least 30 times, varying prompts and model checkpoints. There are five measurement metrics: shape entropy, which tracks how many forms the same field scatters into; the one-line contract violation rate; the parse failure rate for hand-written JSON; content correctness measured independently of format; and realized cost per successful item, in units of what actually gets billed. The fourth metric in particular must be secured with pre-determined ground truth or human grading, and must not be replaced by an LLM judge, because that is precisely where self-favoring bias would contaminate the comparison. What this design is meant to confirm is whether the format-freedom axis actually produces a meaningful difference even when rule count is held fixed, and whether the cost model's dominance condition matches measured data. The authors leave open the possibility of a separate follow-up experiment that also varies rule count, noting that fully separating the incident's two competing interpretations, output-space freedom versus rule conflict, would require exactly that.

## What This Leaves for the Company, Society, and Science

Where this paper is most practically useful is in attaching a quantitative basis to our internal skill-design rules. Which batch skills need a code validation gate and which are fine with prompting alone used to rest only on incident-driven rules of thumb; now it can be judged against two variables, the tier cost multiple and the baseline compliance rate. More broadly, the logic that adding a single code-validation layer, even at a cheap model tier, can get you output reliability on par with a pricier model reads as a basis for lowering the operating cost of automated services that demand precise formats, narrowing accessibility gaps for that kind of service. Scientifically, what is new is setting up an axis, how freely the format is left to the model, orthogonal to the single axis, how many rules there are, that instruction-following-degradation research has mostly measured along until now. Naming a degradation axis that does not overlap with existing rule-count research clarifies, by itself, what future experiments should control for and what they should vary.

## What This Paper Does Not Do

The authors themselves call this an analytical, position-taking paper. No controlled multi-tier compliance measurement was run, and no parameter of the cost model was estimated from real data. The incident is 33 outputs from a single pipeline, a single point in time, and a single model grade, and it does not contain any tier-to-tier comparison to begin with. The claim that output-space freedom explains this better than rule conflict is an argument, not a proof, and does not rule out both mechanisms operating together. The probability variables in the cost model are likewise only discussed qualitatively; no actual value has been estimated. In short, what this paper gives is not an answer, but a question sharpened into a form that can be answered, plus an experiment design that could answer it.

The paper's detail page is [available on Hugging Face](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-12-format-determinism-tier-decay).
