---
title: "When Jev Meets a Corporate Rulebook: a 27B Policy Decision Model"
excerpt: "We put the System One idea of answering typed questions without generating text on top of internal policy documents. On familiar policies, generation really was unnecessary. In front of an unseen rulebook, reasoning was decisive, and teaching the boundaries left a gap. We measured that gap and released the model and the benchmark."
seo_title: "Enterprise policy decision model, 27B open weights - ThakiCloud"
seo_description: "ThakiCloud releases a Qwen3.8-27B-Human-KO-Enterprise decision model that reads a policy and a tool list and picks one of seven actions. Generation-free single-token decisions cut restart-to-restart instability roughly tenfold, and boundary-targeted training cut missed tool calls by 24.8%. Includes three enterprise adoption patterns and where not to use it."
date: 2026-10-02
last_modified_at: 2026-10-02
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cube"
tags:
  - enterprise-agent
  - decision-model
  - system-one
  - policy-compliance
  - tool-use
  - constrained-decoding
  - pointer-head
  - open-weight
  - paxis
  - metis
categories:
  - owm
canonical_url: "https://thakicloud.com/tech-blog/en/owm/enterprise-boundary-decision-model/"
---

If you are building a place where software picks an action under an internal policy, here is the conclusion first. You do not need to generate that decision as text. But where the rulebook changes, do not take away the model's time to think.

These two usually get treated as one thing. Teams switch both off to cut cost, and when quality drops they blame whichever one came to mind. We separated them, and they pointed in opposite directions. On familiar policies, generating text cost something and bought nothing. On unseen policies, reasoning accounted for nearly the whole difference.

We are releasing the 27B policy decision model used in that measurement, together with the benchmark it was scored on. The model is in the `Qwen3.8-27B-Human-KO-Enterprise` line.

![Accuracy on unseen policies across configurations](/assets/images/pace-enterprise-ladder.webp)
*Every bar is the same checkpoint. Only the bottom bar is allowed to reason.*

## Why read this

An [earlier post](/tech-blog/en/owm/lev-system-one-decision-model/) covered the family that answers typed questions with a probability instead of generated text. Jev and its open-weight counterpart Lev are that family, and the point is to drive output tokens to zero so decisions become fast and easy to handle.

What we wanted to know is what comes next. Is a yes/no question about escalating a ticket the same kind of thing as **handing over an entire corporate rulebook and asking for one of seven actions**? Does the same approach carry over?

Half of it did. Dropping generation carried over, and better than we expected. But in front of an **unseen rulebook** the variable was not the format at all. So this is a model release and also a measurement report on how far the System One approach goes before it stops.

## In plain terms

Picture a bank teller again. One who has been there for years knows the rulebook by heart, so the direction is settled before the customer finishes speaking.

Send the same teller to a branch with an unfamiliar rulebook and it changes. Nothing is memorised, so they have to read and work it out. Their ability did not shrink; **the situation changed**.

The model behaved the same way. For enterprise adoption, the question that matters is not "is our model smart" but "is this place a memorised rulebook or an unfamiliar one".

## What the model does

It reads the policy document, the list of callable tools, the facts established so far, and the user's turn. Then it picks **one of seven**.

| Action | When |
|---|---|
| Answer from the policy | The document alone settles it |
| Ask for clarification | A required fact is missing and the user can supply it |
| Ask for confirmation | There is a side effect needing consent |
| Call one tool | Live state has to be checked |
| Call several tools | Two or more lookups are needed |
| Escalate to a human | The policy requires human review |
| Refuse | The policy forbids it |

That choice has to be settled before anything is said. Get it wrong and fluent text makes it worse, not better.

We measured three read-outs: generating a small document, reading **one character** from a vocabulary restricted to seven options, and a **pointer head**, which is the same shape as Jev and Lev.

## Generation can go

On 2,800 familiar items the two formats were effectively identical: 93.5% generating, 94.1% single-token.

The difference showed up elsewhere. Restart the server and ask the same items again, and the generating arm changed its decision for about 3 items in 100, while the single-token arm changed for about 3 in 1,000. Response latency nearly disappears.

For operations the meaning is plain. Handling the same ticket differently today than yesterday happens roughly **ten times less often**. For whoever receives the audit log, that often matters more than accuracy.

## But reasoning cannot

We built and sealed a separate set of 300 items on new policies. The answers were not written by people; they were computed by running a hidden policy through a program. Why we built it that way is in the [paper post](/tech-blog/en/research/enterprise-decisions-learned-or-reasoned/).

![Thinking on and thinking off, across two output formats](/assets/images/pace-enterprise-two-by-two.webp)
*The vertical gap is reasoning. The horizontal slope is the output format.*

Turning reasoning on moved 70.7% to 88.0%. Changing the output format was worth **0.0 points**. In front of an unseen policy, everything that decided the outcome was reasoning.

One more thing worth saying. The pointer head carries the accuracy across but **loses its calibration**: in our measurement its confidence was three times less reliable than the single-token read-out. Given that calibrated probability is the appeal of this family, that is not a number to wave away. If you plan to put those probabilities straight into a threshold, **recalibrate on your own data**.

## Teaching works, up to where you taught

There are two reasons reasoning might be needed. The boundary may genuinely require working through, or the model may never have been taught it.

So we compared a model taught on the boundaries specifically against one given the **same number of tokens** of ordinary data. The decision rule was written down and sealed before we looked.

![Per-boundary accuracy for the two arms](/assets/images/pace-enterprise-boundaries.webp)
*The two taught boundaries open up. The untouched one at the bottom does not.*

The taught boundaries clearly improved: 17.5 points where answering meets calling a tool, 20.0 points where calling a tool meets asking for confirmation. Missed tool calls fell by 24.8%.

The boundary we **deliberately left out** moved 4.4 points with an interval containing zero. That is not a size we can call an improvement. Overall accuracy reached 79.2%, against 88.0% for the same model allowed to reason, leaving 8.8 points.

## How to use this in an enterprise

### 1. Classification and routing on familiar policies: single token

Expense policies, recurring enquiry types, approval workflows — places where **the policy is stable and you have training data**. Do not generate here. A single-token decision is as accurate, much faster, and steadier. On **Metis**, our inference product, this configuration serves directly.

The test is simple. Did the policy document for this place change last quarter? If not, this is the pattern.

### 2. Keep reasoning on where the policy keeps changing

Per-customer policies, new customer onboarding, areas with frequent regulatory revision. What you save by switching reasoning off comes back as wrong decisions. In our measurement that difference was 17 points.

We also measured the compromise of reasoning only on low-confidence items: half the items, 85.7%. It saves something, but less than you would hope, and the reason is clear. On unseen boundaries the model is **confidently wrong**, and a confidence signal cannot catch that.

### 3. When one boundary keeps failing, teach that boundary

If your operational logs show a specific boundary failing repeatedly, build contrastive pairs for that boundary: two situations differing in exactly one thing. In our measurement this beat the same volume of ordinary data.

But **only the boundaries you cover improve**. That makes choosing which boundaries to cover more important than collecting more data. In **Paxis**, our work-automation product, that choice drops straight into operational design.

### Where not to use it

We do not yet recommend it where safety or money is directly at stake *and* the policy changes often. Our measurement found no evidence of transfer to boundaries we did not teach, and we are not going to sell around that. Put human review in those places, and evaluate the model only on whether it reliably chooses **escalate**.

## What we released and what we did not

The weights ship as merged full weights rather than an adapter, so that loading them does not require matching base and library versions. The decision head is included.

All 300 benchmark items are released with their proofs, along with a verifier, so you can check our claims instead of believing them.

**The training corpus is not released.** It derives from internal and licensed sources that we are not in a position to redistribute.

---

The models are on the [ThakiCloud organisation page](https://huggingface.co/ThakiCloud) and the benchmark is [EnterpriseOps-KO Blind-A](https://huggingface.co/datasets/ThakiCloud/EnterpriseOps-KO-Blind-A). Method and limitations are in the [paper post](/tech-blog/en/research/enterprise-decisions-learned-or-reasoned/).
