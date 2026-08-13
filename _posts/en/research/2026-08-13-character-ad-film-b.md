---
title: "The Mascot Ate the Background: We Blamed Training, the Culprit Was the Training Data"
excerpt: "Our character adapter turned every requested scene into the same wall. We read it as a limit of the method. Reshooting the training clips against varied backgrounds made the problem disappear."
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

If you trained a character adapter so a brand mascot could recur across many videos, and the requested scenes keep flattening into the same background, look at the backgrounds in your training clips before you question training as a method. We did it in the opposite order, blamed the method, and found the cause sitting in data we had built ourselves.

## One prompt, three results

![The same prompt generated three ways]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-bgfix.jpg)
*Every row is the same prompt with the same seed. Left is an adapter trained on twelve clips that all share one backdrop, centre is the same recipe retrained after reshooting those twelve clips in twelve different places, right is zero-shot conditioning with no training at all.*

In the left column the office desk, the city skyline at dusk and the cup conveyor are all the same beige wall texture. The mascot is perfectly consistent and the story goes nowhere. That is unusable as a commercial.

The centre column is the same training method with the scenes intact. A desk with plants and shelves, a skyline at sunset, a conveyor stacked with cups, each distinct, and the mascot's form holds throughout. The only difference between those two columns is where the twelve training clips were shot.

The right column is worth a look too. The scenes come out fine, but in the first row the mascot is simply gone, leaving a laptop on a desk. In the third row the shape is there and the eyes are not.

## We blamed the method first

The hypothesis was that a non-face subject would neutralize the face-specific priors that zero-shot methods lean on, so training should win. We generated twelve mascot clips, trained for 400 steps, and ran four methods over the same eight prompts.

Read as a table, training looked fine.

| method | subject fidelity | worst frame | prompt following |
|---|---|---|---|
| baseline (unconditioned) | 0.461 | 0.410 | 0.381 |
| VACE zero-shot | 0.724 | 0.567 | 0.344 |
| Bernini zero-shot | 0.866 | 0.840 | 0.376 |
| trained LoRA | 0.839 | 0.760 | 0.350 |

Open the frames, though, and only the trained arm had lost all eight scenes. A subject fidelity of 0.839 says the mascot survived, not that the scene did. The metric measures the subject alone, so it is structurally incapable of seeing a background collapse. Prompt following barely reacted either, 0.350 against 0.344, because on a short prompt a matching subject term holds the score up even when everything behind it is gone.

So we shipped the final commercial from the zero-shot arm, and at the time we wrote that up as a limit of training.

## Then we changed only the backgrounds

One thing nagged. All twelve training clips shared the same beige studio backdrop, an inevitable consequence of deriving them from a single seed clip, and from the adapter's point of view "this mascot" and "this backdrop" may never have been separable.

So we reshot the same mascot in twelve places, a park bench, a library aisle, a beach at sunset, a snowy street at night, a subway platform, a greenhouse, a bakery display, and retrained. The reference stills were held identical index for index, and rank, learning rate, step count and seed were all fixed. Backgrounds were the only thing that moved.

Measuring the collapse needed a metric. Its signature is that clips given *different* prompts come out looking alike, so we measured similarity between clips rather than distance from a reference, and cropped the centre out so the shared subject would not dominate. Before trusting it we checked it against arms whose answer we already knew by eye: the adapter that visibly collapsed scored highest at 0.906, and the unconditioned baseline lowest at 0.714.

The retrained adapter scored **0.791**, level with zero-shot's 0.792.

| | background collapse | subject fidelity | worst frame |
|---|---|---|---|
| trained, one backdrop | 0.906 | 0.839 | 0.760 |
| **trained, varied backdrops** | **0.791** | **0.843** | **0.819** |
| zero-shot | 0.792 | 0.724 | 0.568 |

What matters is that the mascot survived. Subject fidelity moved by 0.004, which is statistically nothing (p=0.67). This was not a trade of the character for the scenery; it simply stopped teaching the adapter that the backdrop was part of the character.

A second signal normalised alongside it. The collapsed adapter's clip-to-clip similarities had an unusually small spread of 0.022, meaning every pair was alike to the same degree, which is what convergence on a single background looks like. The retrained one sits at 0.060, in the same range as the other methods.

## Which makes this post's original title wrong

This piece first went out under a title saying training lost. Training did not lose. We built the training set badly, and that was fixable.

Comparing again at equal background diversity even shows where training has the edge. At the point inside a clip where the subject degrades most, the trained arm reads 0.819 against zero-shot's 0.568, and that gap is significant (p=0.044). The first row of the figure above, where zero-shot drops the mascot entirely, is what that number is made of. The mean-fidelity gap of 0.843 against 0.724 is *not* significant across eight clips (p=0.16), so the claim available today is about the worst moments rather than the average.

## What this leaves us

When a metric is blind to an axis, the model that fails on that axis rises to first place. Had we picked a winner on subject fidelity alone we would have shipped the adapter that destroyed all eight scenes. The ranking only became legible once we added an axis that scores backgrounds and scene composition separately.

And what looks like a limit of a method is sometimes a property of the data. Shooting twelve clips in one location was convenience rather than design, and that convenience reached the model as a rule: this character lives in front of a beige wall. The smaller the training set, the more readily whatever the shots have in common becomes part of the character.

## The ThakiCloud angle

Mascot clip generation, the twelve-clip training run, the controlled four-way comparison, and the retraining and re-measurement after changing backgrounds all closed inside internal GPUs. The character, a brand asset, never left for an external API. Maxis owns the phases that need training and Metis owns generation and serving.

What actually earned its keep here was not that some method won, but that a wrong conclusion could be tested against our own data and reversed. That the fix belonged in the data rather than the method is also something no amount of reasoning would have told us.

The numbers in this post are measured on internal GPUs, not simulated.
