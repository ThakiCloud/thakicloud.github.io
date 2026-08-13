---
title: "We Made a Mascot Commercial and Training Lost: A Four-Way Measurement on a Non-Face Subject"
excerpt: "We predicted that training would win on a mascot rather than a face, then put four methods on the same eight prompts. Training lost, and the metric we were using showed only half of the loss."
categories:
  - research
tags:
  - video-generation
  - reference-conditioning
  - character-consistency
  - evaluation
  - wan2
author_profile: true
---

> **Correction, 2026-08-13.** After publishing, we ran paired significance tests on this same
> data. The numbers in the table below stand, but **the ordering between methods does not.**
> At n=8 prompts the only significant contrasts are that all four methods beat the baseline,
> and that adapter scale 1.0 beats 0.7. The 0.866 vs 0.839 gap between Bernini and the trained
> LoRA is **p=0.28**. So "Bernini beat training" is not supported, and neither is the title's
> claim that training lost, as a matter of measurement.
> **The decision to ship the zero-shot cut still stands**, because that decision rested on the
> background collapse you can see in the frames below, not on the scores. Collapse is an
> observation, not a hypothesis test.
> One lesson: never turn a difference in means into a ranking without testing it.
>
> **Second correction, 2026-08-14: we found what caused the background collapse.** Above we
> said the collapse stands because it is an observation rather than a hypothesis test. It does,
> but its **cause** turns out not to be training. It was the training data.
> We reshot the mascot in twelve different locations, held every other setting fixed, and
> retrained: the background-collapse score falls from **0.906 to 0.791, landing exactly on the
> zero-shot arm's 0.792**, and the mascot survives intact (subject similarity moves +0.004,
> p=0.67). So the eight scenes flattening into one wall below is a property of *that adapter*,
> not of training. All twelve clips had been shot against the same beige studio backdrop, so
> from the model's point of view "this mascot" and "this backdrop" were never separable. Vary
> the backdrops and the problem disappears.
> Which makes this post's title **wrong**. Training did not lose; we built the training set
> badly, and that was fixable.

If you need a brand mascot to appear across many videos, this post gives you two conclusions. First, **which zero-shot method you pick** separates the results more than the decision to train at all. Second, if you choose a method by looking at how closely the subject resembles the reference, you will probably choose wrong. We nearly did, and what changed our final film was not a number but a frame.

## The result first

<video controls muted playsinline style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/nubo-film-b.mp4" type="video/mp4">
</video>

A 45-second mascot commercial for the fictional brand NUBO COFFEE. It opens on a cafe counter and moves through an office desk, a roastery, a shop window, a kitchen, and a cup conveyor before closing on a studio shot. Across all eight shots the coffee-bean robot keeps the same proportions, the same cyan LED eyes, and the same limb shapes.

![The eight shots in the final commercial]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-shots.jpg)
*The eight final shots. Location and lighting change every time, yet the mascot's form holds.*

The mascot is a fully synthetic character, and the six stills below are the only input any method received.

![Six mascot reference stills]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-refs.jpg)
*These six go in as the zero-shot references. Judge every result below against this form.*

Here is the training data as well, one frame from each of the twelve clips in the training set.

![The twelve clips used for training]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-trainset.jpg)
*Every clip that went into the 400-step run. Look at the backgrounds now: all twelve share the same beige studio backdrop.*

## This commercial was not made by the trained model

The plan was the opposite. In the previous post we found that giving references without training beat training on faces, and we read that as face-specific prior knowledge doing the work. If that was the explanation, then a non-face subject like a coffee-bean mascot should neutralize the advantage and training should win. To check it we generated twelve mascot clips, trained for 400 steps, and ran four methods over the same eight prompts.

Putting the same shot side by side broke the plan.

![Five panels including the reference and the before state]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-fourway.jpg)
*Same prompt, same seed. The prompt: "waves from a shop window shelf, city street bokeh behind glass, evening." With no conditioning at all, the model draws a different robot entirely. And only the trained model lost the scene.*

Start with the before state and the point of this work is obvious. Generate with no conditioning and you get a white android, not a coffee bean. A subject fidelity of 0.461 is what that looks like. All four methods started from there.

The trained adapter preserved the mascot beautifully. But the requested scene vanished and a beige wall texture, apparently carried over from the training data, took its place. This was not a one-shot accident. It happened the same way in all eight shots: the cafe counter, the sack of roastery beans, and the studio lighting all became the same wall. Assembled into a film, the problem is unmistakable.

<video controls muted playsinline style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/nubo-film-b-trained.mp4" type="video/mp4">
</video>

That is not usable as a commercial. The mascot is perfectly consistent, but eight scenes have collapsed into effectively one, so nothing progresses. We rebuilt the final film from the method that won and kept the loser above as the comparison.

## The measurement

We ran four methods plus an unconditioned baseline over eight held-out prompts with fixed seeds. The subject is not a face, so instead of a face embedding we measured similarity to the references with a CLIP image embedding. The worst frame is the point inside a clip where the subject degrades most, and motion is the frame-to-frame change, included so that a near-static output cannot inflate the similarity scores.

| method | subject fidelity | worst frame | prompt following | motion |
|---|---|---|---|---|
| baseline (unconditioned) | 0.461 | 0.410 | 0.381 | 0.025 |
| VACE zero-shot | 0.724 | 0.567 | 0.344 | 0.086 |
| **Bernini zero-shot** | **0.866** | **0.840** | 0.376 | 0.062 |
| trained LoRA (scale 1.0) | 0.839 | 0.760 | 0.350 | 0.079 |
| trained LoRA (scale 0.7) | 0.775 | 0.635 | 0.343 | 0.117 |

Self-similarity among the six references is 0.983, which is the reachable ceiling.

The hypothesis was half right. Training clearly beat VACE, the zero-shot method from the same family, at 0.839 against 0.724. Given that VACE beat training on faces, the ranking did flip, and that much went as predicted. But Bernini, a different zero-shot method, reached 0.866 and also followed prompts better at 0.376 against 0.350. In other words, **which zero-shot method you use** determined the outcome more than whether the subject was a face.

So a claim like "reference-only generation works fine these days," or its opposite, "training still wins," is unverified as long as no method is named. On the same base model, subject fidelity splits between 0.724 and 0.866 depending on which zero-shot implementation you reach for.

## What the metric could not see

The lesson that will outlast the ranking is about measurement.

Read the table alone and the trained LoRA at 0.839 is a strong result that beats VACE by a wide margin. In the actual frames, the trained arm lost all eight scenes and VACE kept them. A subject-fidelity metric is structurally incapable of seeing that failure, because it measures only the subject. The prompt-following metric gave a very weak signal, 0.350 against 0.344, because on a short prompt a matching subject term keeps the score up even when the background has collapsed.

The cause is visible in the training-set figure above. All twelve clips share one beige studio backdrop, so from the adapter's point of view "this mascot" and "this background" were a single inseparable thing. In a twelve-clip run it memorized not only the mascot but **the backdrop it was filmed against.** Shooting the training data against varied backgrounds would probably change this, though that is something we have not measured yet. Lowering the scale to 0.7 restores motion to 0.117 but drops subject fidelity to 0.775 with a worst frame of 0.635. You buy the background back by giving up the mascot, and no point on that trade was good enough to ship.

So we will stop picking winners on subject fidelity alone. At minimum this needs a second axis that scores the background and scene composition, and without it a background-collapsing overfit rises to first place.

## Where training still belongs

Training lost twice across two experiments. That does not mean abandoning it. It does mean the remaining case is much narrower than before.

The firmest ground is a shortage of references. In the face experiment, cutting references from four to one dropped zero-shot subject fidelity from 0.567 to 0.417, below the trained adapter's 0.487, and one persona collapsed to 0.199. The zero-shot advantage is not unconditional; it holds only when several references are available.

Next is campaign economics. A trained adapter needs no reference images at inference. In a pipeline producing hundreds of clips, the overhead of attaching and managing references on every call disappears entirely, and the adapter composes freely with style or motion LoRAs.

Last are properties that existing zero-shot methods simply cannot reproduce: a specific material quality, or a character's signature movement, the kind of attribute a handful of stills does not explain. We have not measured this axis yet, and we will not claim it before we do.

## The ThakiCloud angle

What these two commercials demonstrate is not the superiority of any one method but the position of being able to choose among them. Mascot clip generation, twelve-clip training, a controlled four-way comparison, and a 45-second assembly all closed on internal GPUs, and the character, a brand asset, never left for an external API. With Maxis handling the phases that need training and Metis handling generation and serving, a customer can switch methods while keeping their data.

Worth adding plainly: the method that won here was not training, and we published that result without adjusting it. The value of a pipeline that preserves data sovereignty is not that some particular method wins. It is that you can **measure which one wins on your own data.** We measured, our prediction was wrong, and we changed the final film.
