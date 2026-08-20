---
title: "We Set Out to Train an Orchestrator and Found We Had Four Trajectories"
excerpt: "Teaching a small model to delegate and to stop requires those decisions to survive as labels. We already had the code that produces those labels, and we were throwing them away at collection time."
categories:
  - research
tags:
  - agent-platform
  - distillation
  - training-data
  - orchestration
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/training-an-orchestrator-what-blocks-us/"
---

If you plan to teach agent orchestration to a small model, count whether the data is actually
accumulating before you write any code. We made the plan first and only later found we had four
usable trajectories. The cause was not that the data fails to appear. The labels are produced, and
we discard them during collection.

## What We Are Trying to Teach

An orchestrator in an agent loop makes three decisions. How to cut work into subtasks, who to hand
each one to and with what boundary, and whether the facts gathered so far are enough to answer. The
last one is the stopping decision.

These sit on a different axis from task execution ability. Our distilled 8B gained 26.5%p over its
pre-training baseline on single-shot instruction compliance, but that means "does what it is told
properly," not "knows when to quit."

So it has to be taught separately, and teaching it requires those decisions to be present in the
data.

## They Were Not Present

We counted the local DB. There are 631 execution trace rows. Of those, 41 are orchestrator-side
records and 6 are subagent records.

**Trajectories that include even one delegation: 4.**

Four teaches nothing. No statistics, no holdout, no negative examples.

## The Labels Get Made, Then Dropped

The next part stung more. Separate from the low trajectory count, **even the trajectories we do
accumulate are unusable for training.**

The harness already turns the reason an agent halted into a typed value. Success, hit the turn
limit, loop detected, planned but never acted, all distinguished. Several handlers read that value
and act on it.

Yet across the entire module that builds training data there is **not a single reference** to it.
The moment we export, the halt reason disappears.

Even if we wire it up, the next problem is waiting. The emitting side writes a string with an
underscore in it, and the receiving side classifies by looking for a string with a space in it. One
character apart. So a run that died against the turn limit gets classified and exported as **no
failure**.

The exact pathology we want as a negative example ships out as a clean success.

Third, the table holding execution outcomes has 402 rows locally and the export code does not join
against it. Whether the run succeeded or failed never rides along on the Episode.

With neither the halt label nor the success label, what remains is a list of which tools got called.
You cannot teach "when should I stop" from that.

## Collect Only Successes and You Teach It to Delegate More

Even with the label wiring finished, the data design catches you once more.

Gather only successful trajectories and the model learns "delegating works out." What it actually
needs to know is when **not** to delegate. Splitting off work you could have done yourself only adds
round trips and slows things down.

So the negative examples have to be manufactured on purpose. Delegated when it should have acted
directly, acted directly when it should have delegated, re-delegated because it did not trust the
worker's result, stopped too early, never stopped at all. You cannot wait for these to occur
naturally. You design scenarios and pull them out.

## And It Cannot Exceed Itself

Here is the strongest objection to this whole approach, written down.

The trajectories we would collect are made by the 27B. Train a small model on them and the student
can only do as well as the 27B does. Delegations the 27B judged wrong become training signal just
the same.

Which means this training does **not make orchestration better.** The ceiling is doing the same
quality more cheaply.

That changes the question. Not "can we train orchestration" but **"how much quality do we lose and
how much cost do we save."** By our measurement, one pass of the 27B orchestrator produced 13,125
output tokens against 917 for the 8B worker. The parent side dominates, so the room to save is real.
Whether that saving justifies the quality loss is something you settle by fixing the numbers in
advance, not by trying it and seeing how you feel about the result.

## So We Reordered

The original plan was to write the training plan first. The order now is this.

Fix the label wiring first. Put the halt reason on the Episode, align the marker strings, and pin
that incident with a regression test, because a one-character mismatch comes back quietly even after
you fix it. Join the execution outcome table too.

Then build trajectories. Design scenarios and run the 27B orchestrator repeatedly, composing
situations so that the negative examples above actually show up rather than successes alone.

Then, once the scale is visible, decide whether to train at all. Fix a ceiling on quality loss and a
floor on cost saving as numbers first, and if that inequality does not hold, do not train.

## What Is Left

What we got this round is a diagnosis, not a plan. We thought training orchestration would be hard.
Opening it up, it was not hard so much as **not yet startable.** Four trajectories, and even those
ship without the labels we need.

Had we planned without measuring, we would have built a multi-week training plan on top of four
rows of data. Counting first is what we saved.
