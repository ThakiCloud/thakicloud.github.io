---
title: "If Your Mascot Keeps Standing There, Change the References, Not the Prompt"
excerpt: "We asked for twelve distinct actions and mostly got twelve standing poses. Replacing every verb with a whole-body one changed nothing. Replacing the four reference stills did."
categories:
  - research
tags:
  - video-generation
  - character-consistency
  - reference-conditioning
  - evaluation
  - wan2
author_profile: true
---

If you generate character video from reference images and the requested motion keeps collapsing back to a standing pose, check whether all four of your reference stills show the character standing before you rewrite the prompt. We rewrote the prompt first, measured it, and nothing had changed.

## What we changed and what moved

We built three training sets. All three share the same twelve backgrounds and the same seed, and the control repeats a single action twelve times.

The first (v2) used twelve upper-body gestures performed while standing: waving, clapping, pointing. The second (v3) threw that vocabulary out and replaced it with twelve whole-body verbs, things like jumping high, crouching to the floor, spinning in place, running across the frame. The reference stills stayed exactly as they were in v2.

The third (v4) inverted the change. The prompts and seeds are character-for-character identical to v3 and only the four reference stills differ.

![The four reference stills]({{ site.url }}{{ site.baseurl }}/assets/images/mascot-ref-pose-v3-vs-v4.jpg)
*The top row is what v2 and v3 used. Four different expressions, four identical standing poses. The bottom row is v4: neutral, walking, mid-jump, crouched, chosen to span the pose space rather than the expression space.*

The numbers below measure how differently the twelve clips in a set move, relative to the single-action control. Larger means more varied.

| training set | references | prompts | gap vs control | p |
|---|---|---|---|---|
| v2 | four standing poses | twelve upper-body gestures | +0.0173 | 0.010 |
| v3 | same as v2 | twelve whole-body verbs | +0.0172 | 0.016 |
| v4 | four distinct poses | same as v3 | +0.0272 | 0.0025 |

v3 matches v2 to four decimal places. Rewriting the entire action vocabulary bought 0.0001. Changing only the references widened the separation by 58 percent.

![Same prompts, different references]({{ site.url }}{{ site.baseurl }}/assets/images/mascot-action-v3-vs-v4.jpg)
*The same six prompts at the same seed. v3 on top, v4 below. Look at whether "crouch" actually reaches the floor and whether "topple over" actually falls.*

<video controls muted playsinline loop style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/mascot-ref-pose-v3-vs-v4.mp4" type="video/mp4">
</video>
*Still frames only tell half of it. The same six prompts at the same seed, side by side. The left arm mostly holds a standing pose; the right one leaves the ground, drops to it, and falls over.*

## References constrain pose, not just appearance

Reference conditioning is usually explained as telling the model what the character looks like. It also tells the model how the character stands. When all four stills show a standing character, the model learns that this character is a standing thing. The prompt can ask for a crouch, but the references are simultaneously asking for a stand, and the references win.

This matters because of cost asymmetry. Rewriting a prompt feels free, so it is what you reach for first. Regenerating a reference sheet means producing and curating new images, so it feels expensive. We did the cheap thing first and it was wasted work. The order should have been reversed.

## More seeds bought no power

Plenty to be honest about here. Each of the three sets above is twelve clips, and pitting v3
directly against v4 gave p = 0.148. So we generated two more seed replicates, taking each arm to
thirty-six clips.

All three seeds agreed in sign, with effect sizes of +0.0100, +0.0082 and +0.0096 sitting almost
on top of each other. Pooled, p was still 0.123. The strange part is that **tripling the clips
barely moved the spread chance produces**, from 0.0097 to 0.0087.

The cause is the unit of independence. All three seeds use the **same twelve prompts**. There are
thirty-six clips but still only twelve distinct questions, and adding seeds mostly re-asks the same
question. Buying power required more scenes and actions, not more seeds. That cost six GPU hours to
learn.

So we matched the statistic to the structure. v3 and v4 share their prompts, so they can be paired
per prompt. Scoring each clip by how closely it resembles the rest of its own set and pairing across
prompts gives p = 0.0151, or 0.0269 by signed rank. **Significant.**

But this is significance obtained by changing the statistic. The first test was not significant and
the second was. However sound the reasoning, the shape is the shape of p-hacking. In our defence,
the switch came from observing that the null spread failed to shrink and diagnosing why, not from
looking at the result. Still, the statistic was not fixed in advance.

What to take away: **the prompt-vocabulary half is solid.** v3 matching v2 to four decimal places
needs no test at all. **The reference-pose half is directionally consistent across three seeds and
significant under the paired test, but not under the set-level one.** Read both numbers.

## The metric was measuring backgrounds

One trap here is worth someone else's time. To score action diversity we extracted a motion signature from frame differences and compared clips pairwise, and the first implementation used the **whole** frame. Since every clip has a different background, the steam in the cafe and the surf at the beach and the lamplight on the snow all entered the measurement as motion.

Cropping to the central 60 percent cut the null distribution's standard deviation by more than half, and two verdicts that had read "not significant" flipped. The advice to vary your backgrounds and the requirement to measure action diversity pull against each other: the moment backgrounds vary, a whole-frame motion metric stops working.

Thresholds are better derived than chosen, too. Pool both sets of clips, re-split them at random two thousand times, and the distribution tells you how large a gap chance alone produces. The 0.05 threshold we started with sat roughly four times above the 95th percentile of that distribution.

## Zero-shot was more stable than training

A separate result from the same experiment family. We compared a trained reference-conditioning adapter against zero-shot conditioning with no training, across four seeds.

Identity similarity itself does not separate the two. But per-frame identity within a single clip wobbles significantly more on the trained arm: 0.153 against 0.071 on the face-recognition metric, and 0.082 against 0.055 when re-scored with an embedding metric that needs no face at all. When two different instruments say the same thing and the sign holds at all four seeds, it is not seed luck.

Incidentally, four references preserve identity better than one, confirmed on both instruments. That one needs no training at all. It is a single argument at inference time.

## What a varied training set buys is not variety

One more measurement from the same family. Two adapters, trained under identical settings, same
step count, same rank, same references. The only difference is whether the twelve training clips
carry twelve distinct actions or one action repeated twelve times. Both were then asked for twelve
held-out actions that appear in neither training set, because replaying a learned motion is not
generalization.

The expectation was that the twelve-action adapter would render unseen actions more variously.
**It does not.** The difference in output diversity is about an eighth of the spread chance alone
produces, at p = 0.42. Diversifying the training set does not diversify the output.

Something else moved. Paired over the same prompts, per-frame identity spread within a clip drops
from 0.0384 to 0.0133, a 65 percent reduction, at statistically identical mean identity. The first
suspicion was that the twelve-action arm simply moves less, but the motion difference is not
significant and across all twenty-four clips the correlation between motion and drift is
essentially zero.

![Held-out action comparison]({{ site.url }}{{ site.baseurl }}/assets/images/mascot-e17-holdout.jpg)
*Four actions absent from both training sets, sampled at the start, middle and end of each clip.
Neither adapter renders the requested action convincingly. What to look at is how well the
character holds together across the three frames.*

<video controls muted playsinline loop style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/mascot-e17-holdout.mp4" type="video/mp4">
</video>
*Five held-out prompts. Neither adapter performs the requested action. Watch the left panel for the moments where the character's design slips as the clip runs.*

An adapter that has seen one motion fights the prompt when asked for something else, and that
conflict surfaces as identity wobble. An adapter that has seen variety does not fight. Training
diversity buys **stability under unfamiliar requests**, not range.

## The ThakiCloud view

Character design, reference generation, training-set construction, adapter training and evaluation all stayed inside our own GPUs. The brand asset never left for an external API. Maxis owns the phases that require training; Metis owns generation and serving.

What earns its keep is being able to run the measurement at all. "Reference pose constrains motion" sounds plausible, and plausible hypotheses are mostly wrong. Without measuring it against your own data you keep rewriting prompts and never learn why they do not work.

Every image and clip here was generated on our own GPUs, and the numbers are measurements rather than simulations.
