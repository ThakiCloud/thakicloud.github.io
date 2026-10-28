---
title: "Is Curiosity a Computable Signal? How Schmidhuber Formalized Interestingness as an Inductive Heuristic for Future Compression Progress at ICML 2026"
seo_title: "Interestingness as an Inductive Heuristic for Future Compression Progress: Schmidhuber ICML 2026 position paper, compression progress, curiosity formalized, Kolmogorov complexity, open-ended agents - ThakiCloud"
seo_description: "Herrmann and Schmidhuber's ICML 2026 position paper formalizes 'which task has potential for future progress' as a computable signal. What the two results say, expected future progress depending exponentially on the recency of the last breakthrough and the Algorithmic prior being quadratically more optimistic than the Length prior, and how the heuristic plugs into unattended agent-loop scheduling."
excerpt: "A thread went viral claiming a paper answers why anything is beautiful and why jokes are funny. The paper behind it is Herrmann and Schmidhuber's ICML 2026 position paper, and its actual claim is narrower. Interestingness, the potential for future compression progress, is predictable from past progress records. Here is the formalization, the results, and the path to agent scheduling."
date: 2026-10-29
tags:
  - interestingness
  - compression-progress
  - intrinsic-motivation
  - curiosity
  - schmidhuber
  - icml-2026
  - position-paper
  - kolmogorov-complexity
  - open-ended-agents
  - self-improvement
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/interestingness-inductive-heuristic/"
lang: en
---

## Who should read this, and what you will get

This post is for developers running unattended agents or open-ended systems who still pick "what to explore next" by hand, and for data scientists who need a criterion when choosing what to learn from.

Here is the conclusion first. This paper formalizes "which tasks hold potential for future progress" as a signal you can compute and predict from past compression-progress records, an inductive heuristic. Under three computable priors, it proves that expected future progress depends exponentially on the recency of the last observed breakthrough, and that the Algorithmic prior is quadratically more optimistic than the Length prior for the same observed profile, with experimental confirmation across three universal computational paradigms. If you run agent loops, you just gained another candidate objective function for "what to pick next."

![Abstract image of a chaotic line of light folding into ordered concentric rings: the process of data becoming simpler as it is compressed through learning](/assets/images/interestingness-inductive-heuristic-hero.webp)
*The post's core concept visualized: a complex signal compressing into an increasingly simple structure as learning proceeds.*

## Context

Around October 27, a passage started circulating on X. "This paper answers why anything is beautiful, why jokes are funny, why we get curious, why you get bored, why babies explore, why music has hooks." It depicts the brain as "a relentless compression engine" and describes dopamine flooding in the moment a pattern is found, carrying over the legend-like sentences of this research lineage.

The paper behind it is "Interestingness as an Inductive Heuristic for Future Compression Progress" by Vincent Herrmann and Jürgen Schmidhuber. It was registered on [arXiv 2605.14831](https://arxiv.org/abs/2605.14831) on May 14, 2026, accepted to the [ICML 2026 Position Track](https://proceedings.mlr.press/v306/herrmann26a.html), and the [project page](https://inductive-interestingness-2026.github.io/future-compression-progress/) links the code. The authors are affiliated with the Swiss AI Lab IDSIA/USI/SUPSI in Lugano, Switzerland, and KAUST in Thuwal, Saudi Arabia.

One boundary must be drawn, though. The claims about beauty, jokes, and babies exploring are not from this 2026 paper. They belong to Schmidhuber's 2008 paper [Driven by Compression Progress](https://arxiv.org/abs/0812.4360), whose title itself lists "Subjective Beauty, Novelty, Surprise, Interestingness, Attention, Curiosity, Creativity, Art, Science, Music, Jokes." Where the 2008 paper explains "why humans experience what they experience" via compression progress, the 2026 paper pushes one step further and asks "can the signal itself be predicted in advance." The viral thread merged the two. This post writes from that boundary.

## In plain terms

An analogy from venture investing. An investment firm watches the growth charts of hundreds of startups every day. It does not put money into startups whose revenue has already hit the ceiling. It also does not look at startups whose numbers are flat. It looks at exactly one thing: startups whose recent curvature is alive, the ones that broke through last quarter.

The interestingness this paper formalizes is the mathematical version of that "recent curvature." When data or a task is given to a learner, a curve forms showing how much the learner can compress (simplify) it over time. The next advance is most potential where that curve just became steep, and least where it bent once long ago and went flat. That is the first result.

The second result maps to "types of investors." An accountant's eye, counting only revenue (Length prior), and a venture partner's eye, reading the tech stack and pipeline structure (Algorithmic prior), extract different expectations from the same startup. The paper proves that the second eye, given the same past record, expects much larger future discovery than the first, and that the gap widens not linearly but quadratically.

*The analogy above is the author's interpretation. In the paper, the two "eyes" are specific priors, the startups are complexity profiles of binary strings, and the discoveries are the next drops.*

## The problem the paper sets up

The paper names the "interestingness problem" as a bottleneck on the way to recursively self-improving systems. The minimal picture of open-ended intelligence is a cycle of two phases. The learning phase extracts patterns and skills from data with gradient descent or reinforcement learning. The generation phase turns those insights into new artifacts. For the cycle to keep turning indefinitely, the generation phase needs one criterion: one that distinguishes "structure worth learning" from "already-known knowledge, or noise." In the paper's Figure 1 wording, a criterion that distinguishes "learnable structure from noise or already-acquired knowledge."

This paper places the definition of that criterion as follows. Interestingness is "an inductive heuristic for future compression progress," not "how surprising is this data right now" but the expectation of "how much more can this be compressed after I learn it." The latter view sits on the same line as the "first derivative of subjective beauty, the steepness of the learning curve" that Schmidhuber already wrote in his 2008 paper.

Section 2 maps the territory carefully. It classifies existing interestingness criteria into eleven families and places the compression-progress family and this paper within them: count-based, space coverage, maximum entropy, prediction error (and adversarial), information gain, Bayesian surprise, learning progress, competence progress, compression progress, open-endedness derived from social multi-agent interaction, and the family claiming "LLMs can predict human-distilled interestingness." The last line is what makes this paper worth reading today. Beyond the formalization, a practical path, approximating the criterion itself with an LLM judge, is already inside the territory.

Section 3 connects the formalization to "current machine learning." The concept of a complexity-runtime profile is mapped three ways. Neural network training with gradient descent becomes "the profile where required complexity falls as training time on the same data grows." Chain-of-thought and recurrent reasoning become "the profile where the length of generated reasoning is the runtime." Model scaling enters as "the reading where parameter size moves the complexity-runtime tradeoff." This mapping is the paper's practical value. It is not abstract formalization; the curve an engineer training today is looking at is exactly that profile.

On top of that, section 3.2 moves to combinatorics: counting how many strings have a given profile, and the probability that the next drop comes for such a string.

## Key results

The formal toolkit is Kolmogorov complexity and algorithmic statistics. All data and artifacts are treated as binary strings x, and K(x) is taken as the length of the shortest program that outputs x on a universal machine (prefix-free Kolmogorov complexity). The moments when the required complexity of an observed string "drops" as the learner improves are compression progress, and the temporal arrangement of those drops is the profile.

With that, the paper computes "expected future progress given the profile observed so far" under three computable priors: Length prior, Algorithmic prior, and Speed prior. The results (all proofs fill Appendix A) are two.

First, expected future progress depends exponentially on the recency of the last observed breakthrough. If only old breakthroughs have accumulated, expectations fall quickly. In domains where progress just happened, expectations rise exponentially.

Second, for the same observed profile, the Algorithmic prior is markedly more optimistic than the Length prior, and the gap widens quadratically in expected discovery. Intuitively: "the eye that reads algorithmic structure" raises expectations of the next breakthrough much faster than "the eye that only counts length."

The three priors are tools that answer the same question ("what is the expected value of the next advance?") with different approximations. The Length family takes length, the Algorithmic family takes algorithmic structure, and the Speed family takes computational speed as its respective standard for weighting the probability of the next drop. Which prior is more optimistic is, in the end, the difference of "through which eye you look at learning."

The paper states that these two results are confirmed experimentally across three distinct universal computational paradigms (cited at abstract level; section 5 of the body treats experiments such as the 2-Tag Rule).

```mermaid
flowchart TB
    O[Observation: the learner's<br/>complexity-runtime profile] --> P[Chosen prior<br/>Length / Algorithmic / Speed]
    P --> E[Expected future compression progress<br/>probability and size of the next drop]
    R[Recency of the last breakthrough] -.exponential weighting.-> E
    E --> S[Interestingness signal<br/>potential for future discovery]
    S --> G[Generation phase: pick the next target]
    G --> L[Learning phase: extract patterns]
    L --> O
```
*The paper's learning-generation cycle with a "predictable interestingness signal" layered on it. The recency weighting decides the direction of the next rotation.*

## Implications for ThakiCloud products

[Paxis](https://thakicloud.com) by ThakiCloud is an Agent-Native Cloud where unattended agent loops run continuously. Moments that decide "what to run next," such as the overnight experiment queue (research lab loop), skill self-evolution, and the paper factory, happen every day. Today, those decisions are owned by human-designed queues and simple heuristics like escalating the model after consecutive failures.

This paper offers a computable candidate objective for that decision. The evaluation-score curves or cost curves of each domain are physical instances of "compression-progress profiles," and computing expected future progress over that profile with a prior yields the ranking of "which experiment to rerun, which new candidate to queue." The recency weighting of the last result matches the intuition "look harder at domains that just broke through," so the adoption barrier is low.

The family claiming "LLMs can predict human-distilled interestingness" meshes directly with ThakiCloud's agent production stack. In the stack's evaluation structure, heuristics cover 100% of traffic while the LLM judge covers 5 to 10 percent, and "is this experiment result worth re-exploring?" is a natural candidate task for the LLM judge.

## Limitations and counterarguments

Six, compressed.

First, it is a position paper. It builds no new system and does no large-scale empirical validation. The body's experiment section is a small setting across three paradigms, and the force of the results sits in the combinatorial proofs of the appendix.

Second, K(x) is uncomputable. Every result is relative to a chosen prior, and Length/Algorithmic/Speed are approximations that route around that uncomputability. The claim "expected discovery is quadratically larger" is a result inside those approximations, not a law of physics.

Third, observer relativity. As the 2008 paper presupposes a "self-improving, but computationally limited, subjective observer," interestingness is defined relative to a specific learning program's eye. It is not an objective property of the data; it is a property of "what that agent can gain next."

Fourth, the boundary with the viral wording. The descriptions of dopamine, beauty, and babies exploring are not claims of this 2026 paper. Not confusing them with the 2008 lineage when citing is the duty of anyone using this theory.

Fifth, the practical degeneration risk of recency exponential weighting. The rule "look harder where breakthroughs just happened" can turn into trend-chasing depending on how a domain defines "breakthrough."

Sixth, half the cycle is still empty. This paper gives the generation phase a "selection criterion." The cost of actually producing progress, from the target that criterion picks through to the learning phase, is outside this paper's scope.

## Summary

We collect the conclusion set in the introduction. The question "what should we explore next" becomes a computable signal once you look at past progress profiles. The two results, expected future progress depending exponentially on recency and quadratically on the prior choice, guarantee that.

For those running agents, the suggested next action: reinterpret the evaluation curves of the experiments and data candidates stacked in your queue as "compression-progress profiles." Attaching a score that computes expected future progress from the last drop point and the slope of those curves is the first step of moving this paper into a system.

In one line. Curiosity is no longer a psychological concept. It is an objective function you can optimize.

## Sources

- Herrmann, V., & Schmidhuber, J. (2026). [Interestingness as an Inductive Heuristic for Future Compression Progress](https://arxiv.org/abs/2605.14831). arXiv:2605.14831.
- [Position: Interestingness is an Inductive Heuristic for Future Compression Progress](https://proceedings.mlr.press/v306/herrmann26a.html), ICML 2026 (PMLR v306).
- [Project page](https://inductive-interestingness-2026.github.io/future-compression-progress/)
- Schmidhuber, J. (2008). [Driven by Compression Progress: A Simple Principle Explains Essential Aspects of Subjective Beauty, Novelty, Surprise, Interestingness, Attention, Curiosity, Creativity, Art, Science, Music, Jokes](https://arxiv.org/abs/0812.4360). arXiv:0812.4360.
- Viral thread: [@HowToPrompt__](https://x.com/HowToPrompt__/status/2115042117085221160) (2026-10-27)
