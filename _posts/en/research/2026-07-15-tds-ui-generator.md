---
title: "If You Want an LLM to Generate Screens From a Design System, Build the Gate Before the Model"
seo_title: "TDS UI Generator: Constraints Over Training, and Why Selection Matters - Thaki Cloud"
seo_description: "A field report on ThakiCloud's design system (TDS) console UI generator experiment. A 27B fine-tune failed the gate at 0/40, but registry-based constrained decoding passed 39/40 with no training at all. Validity and fidelity turned out to be different axes, and the remaining bottleneck wasn't generation but selection, where a requirement-based selector beat an LLM judge."
excerpt: "We expected fine-tuning to win. The data said otherwise. Here's how we ended up with a generator that respects TDS without any training, and the next problem we're chasing: a valid screen isn't the same as a good one."
date: 2026-07-15
tags:
  - llm
  - constrained-decoding
  - structured-generation
  - ui-generation
  - design-system
  - evaluation
  - verifier
categories:
  - research
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/tds-ui-generator/"
---

This is a field report from our platform team on building a model that automatically generates
desktop console UI screens using the THAKI Design System (`@thaki/tds`). It's written for
frontend and ML engineers who are trying to get an LLM to produce UI. The short version: what
determined the quality of the generated screens wasn't model size, it was **the gate that
actually compiles and validates what gets generated**.

![Banner showing the TDS UI generator experiment result flipping from 0/40 with fine-tuning to 39/40 with constrained decoding]({{ '/assets/images/posts/research/tds-ui-generator/hero.webp' | relative_url }})
*Instead of teaching the grammar through training, we forced only valid outputs through rules.*

## Why we didn't generate code directly

Generating long JSX in one shot from a screenshot or a requirement has a well-known failure
pattern: elements go missing, hierarchy gets twisted, layouts flatten out. We carried over a
principle we'd already learned elsewhere: preserve general-purpose knowledge and train hard
only on the domain-specific part, and applied it to UI. The model never touches pixels or code
directly. It only produces two intermediate representations. First, a design-system-agnostic
UX-IR that expresses "what does this screen do." Then a TDS-IR that expresses "which TDS
components realize that." The actual code is owned by a deterministic compiler, not the model.
TDS already implements padding, typography, and interaction behavior, so the model doesn't need
to relearn style. It only needs to learn which components to use and how to structure them.

## What we built first wasn't the model, it was the registry and the gate

We analyzed the `tds_ssot` repository and auto-extracted the props, slots, and enum values of 61
components, along with which components are allowed in which slots, into a Component Registry.
Rules like "Button's variant must be one of eight values" or "only certain components are
allowed in FormField's control slot" all live here. One interesting discovery was that
`@thaki/tds` isn't a mobile system. It's a desktop console system built around Table, Drawer, and
Modal, which is also why the demo lives under `/desktop`. So we mapped UX roles to TDS components
with console patterns in mind.

We made the code, not the model, own the gate. It deterministically checks whether a component
actually exists, whether a prop is a defined value, whether the slot compatibility holds, whether
clickable elements have an action attached, and whether primary buttons are duplicated. A model
self-reporting "I built this well" is not verification. Compiling and passing the schema is.

## Is 100 samples enough data

We started with 100 user request samples. Here's the honest part: full fine-tuning a 27B model
on 100 examples guarantees overfitting and mode collapse. So instead of treating the 100 as a
27B training set, we used them to prove out the pipeline. We synthesized realistic console screen
patterns with a probabilistic grammar, and only derived training examples from screens that
passed the gate. From a single screen we extracted multiple tasks: text-to-UX-IR, text-to-TDS-IR,
edit-instruction-to-JSON-Patch, recovery from a broken IR, and even preference pairs of matched
good and corrupt outputs. Of 22 seed screens that passed the gate, 20 yielded 100 SFT examples
and 20 preference pairs. We stuck to the principle that what matters isn't the volume of data but
whether it passed an executable check.

## The single most important number

The most valuable result we got from this project wasn't a training curve, it was a comparison of
how discriminating our different metrics were. We took a correct reference IR, deleted one
component, corrupted an enum value on a prop, and measured how well various metrics caught the
damage.

| Metric | Normal | Corrupted | Change |
|---|---|---|---|
| component F1 (similarity) | 1.00 | 0.81 | barely moves |
| valid-prop rate | 1.00 | 0.30 | collapses |
| schema-valid rate | 0.93 | 0.23 | collapses |
| compile-ok | 1.00 | 1.00 | no reaction |

The similarity-based metric was lenient, and compile success didn't react at all. The compiler
just emits invalid props as-is, so compiling successfully doesn't mean the quality is good. By
contrast, schema validation and prop validity reacted precisely to the corruption, dropping to
under half. In other words, if you align generation quality to similarity or compile success
alone, you'll get it almost right, but you won't catch the wrong outputs. Quality is created by a
gate that closes the loop through compiling, schema, slots, and interaction.

## We plugged in training, and it honestly failed

Everything up to here is a harness story. What follows is actual training. We ran the data engine
to produce 5,924 training examples from 1,185 gate-passing screens, attached LoRA to
Qwen3.6-27B, and trained on our internal H200 cluster. Training itself converged well: loss
dropped to 0.07, and token accuracy hit 96%. Then we served the trained adapter and compared it
against the base model.

The result, honestly, was a failure. A 300-step diagnostic LoRA barely changed the auto-generation
output at all. The error profile before and after training was effectively identical. Both models
attached input attributes directly to FormField, and both added a title to Card, which doesn't
support one. The real design system wraps an input inside FormField through a nested slot
structure, but both models were imagining a flatter structure.

Digging into the cause turned up three factors. Training was short, and token accuracy saturated
early, so the gradient signal was weak. More importantly, it was a data problem. The realize
function that generated our synthetic data never showed the true nested structure, so the model
had no way to learn a contract it never saw. And the 27B model's existing habits were strong.

That's where the second lesson came from. All three proxy metrics missed the real generation
quality. Compile success, teacher-forced token accuracy, and the change in token accuracy after
attaching LoRA all diverged from the gate pass rate. Only an execution gate against the full
registry exposed the real gap the two models shared. Along the way we also discovered our
registry itself was incomplete and had been dropping perfectly valid outputs, so we did a full
extraction of the properties of 30 components and fixed it.

## So we fixed the data, retrained, and finally found the answer

We rewrote the realize function to produce the actual nested structure. FormField now wraps its
input in a slot, and each component uses its real attributes. That yielded 2,771 screens that
cleanly passed the gate, from which we generated 13,855 training examples. This time we trained
much longer, running 1,500 optimization updates.

Even so, the trained model still failed the gate. Before and after were nearly identical again.
At this point it became clear: for this problem, the 27B model's flattened habit was not going to
budge with a training budget we could reasonably afford.

So we changed direction. Instead of trying to persuade the model, we forced the generation itself.
We auto-generated a JSON schema from the registry: only real component names, only attributes
that component actually has, and nested structures enforced recursively. We applied this as a
decoding constraint. The result was clear. On the same 40 held-out examples, with no training at
all, the gate pass rate went from 0% to 39 out of 40, or 97.5% (95% CI 86.8% to 99.9%).

![Bar chart of gate pass rates across base, fine-tuned, repair, and constrained-decoding methods]({{ '/assets/images/posts/research/tds-ui-generator/fig1-reversal.webp' | relative_url }})
*Four-way comparison: constraint alone, without any training, pushed the gate pass rate to 39/40. Measured (n=40).*

This three-way comparison is the conclusion of the project. Both the untreated base model and the
fine-tuned model scored 0/40, while the base model with constrained decoding alone passed 39/40.
When a model with strong ingrained habits needs to produce structured output, under these
conditions, constraining decoding with rules like an execution gate was cheaper and more reliable
than trying to fine-tune the habit away.

From here on we have to stay honest. First, it's 97.5%, not 100%. The one that didn't pass was
constrained too, but the JSON got cut off mid-generation. Schema constraints don't fully
guarantee even parseable JSON. Second, this win was a win for validity, not quality. Component
similarity (F1) against the reference screen actually went down slightly under constraint (from
0.317 to 0.292). Being valid and matching the requested intent are different things, and that gap
is the real homework for the next stage. Third, don't misread why the pass rate is so high. We
initially wrote that this 100% was because the schema mostly subsumes the gate, but when we
actually contrasted the two rule sets against adversarial cases, it was the opposite. The gate
was stricter than the schema. The schema only blocks the two most common errors, nonexistent
components and missing attributes, and let through violations like a missing schemaVersion or
placing the wrong component in a slot. Catching those was the gate's job. So constraint paid off
because the schema eliminated the dominant failure type, and what remained happened to also
satisfy the gate's stricter rules. The real by-construction risk is that the schema and the gate
both come from the same registry, and that can only be ruled out by a verifier outside the
registry, such as React rendering and TypeScript type checking.

## A valid screen wasn't the same as a good screen

If we stopped here, the conclusion would be "constraint is the answer," but that's only half the
truth. We dug further. We extracted requirement contracts from the held-out reference screens and
measured how well each method actually reproduced the screen's real content. The result stung.
Constraint had the highest validity, but the lowest reference information and component
recovery. We had bought validity with no training, but content fidelity was lower than even the
untreated base model. Repair, which deterministically patches the base output without any GPU
work, and free-planning-then-constrain both had the same problem. Both traded validity for
content. Being valid and matching the requirement turned out to be different axes.

## So we measured where to invest first

The next instinct was to make the model bigger or generate several and pick the best. Before that,
we asked a simpler question: if you generate eight times, is there actually a good one in there?
We generated eight constrained candidates per prompt and compared a single sample against the
best candidate: 0.29 versus 0.45. Good screens were already being generated. What we couldn't do
was pick the good one out of the batch. The bottleneck wasn't generation, it was selection.

## The selector needed to be a requirement, not a judge

So we built several selectors that don't know the ground truth, and measured how much of that
ceiling they actually captured.

![Bar chart comparing component F1 across Top-1, structure, judge, requirement, and oracle selectors]({{ '/assets/images/posts/research/tds-ui-generator/fig2-verifier.webp' | relative_url }})
*Among selectors that don't know the ground truth, the requirement predicate recovered 27% of the headroom, while the LLM judge did worse than not selecting at all. Measured (n=40).*

Picking the structurally richer candidate barely helped. Picking the candidate that passed the
gate actually made things worse, another confirmation that selecting for validity costs you
content. Asking the base model directly which candidate was best did worse than picking nothing
at all. One thing worked: extracting what the screen needs to contain from the prompt first, then
picking the candidate that best satisfies that requirement. That captured a quarter of the
selection headroom. The selector, it turned out, needed to be a requirement, not a judge.

Looking back at the whole project, four lessons remain. First, the place to invest first isn't a
bigger model, it's the scaffolding that actually executes and verifies what gets generated.
Second, that scaffolding has to be accurate, or both failures and successes look wrong. Third,
when strong habits collide with structured output, at least for this problem, constraining was
cheaper than pushing training harder. We're not generalizing that to every case. Fourth, validity
and fidelity are different axes, the remaining bottleneck is selection rather than generation, and
that selector needs to be requirement-based rather than judge-based. What we need to prove next is
raising the selector and semantic accuracy together using human-written requirement contracts.

## References

Here are the external techniques this experiment leaned on.

- Theoretical foundation for constrained decoding, the method that ultimately won: Willard, Louf,
  [*Efficient Guided Generation for Large Language Models*](https://arxiv.org/abs/2307.09702).
  This is the approach of constraining decoding with a schema or grammar so that only valid output
  can come out.
- The open-source library that actually implements the above approach:
  [Outlines (dottxt-ai/outlines)](https://github.com/dottxt-ai/outlines).
- The parameter-efficient fine-tuning method we tried and that failed for us: Hu et al.,
  [*LoRA: Low-Rank Adaptation of Large Language Models*](https://arxiv.org/abs/2106.09685).
- The root of best-of-N sampling and verifier-based selection, picking the good one out of eight
  generations: Cobbe et al.,
  [*Training Verifiers to Solve Math Word Problems*](https://arxiv.org/abs/2110.14168).
