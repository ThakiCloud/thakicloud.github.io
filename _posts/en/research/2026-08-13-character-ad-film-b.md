---
title: "The Mascot Ate the Background: We Blamed Training, the Culprit Was the Training Data"
excerpt: "Our character adapter turned every requested scene into the same wall. We read it as a limit of the method. Reshooting the training clips against varied backgrounds fixed it, and let us rebuild the commercial."
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

## The result first

<video controls muted playsinline style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/nubo-film-b-bgfixed.mp4" type="video/mp4">
</video>

A 45-second mascot commercial for the fictional brand NUBO COFFEE, generated from a single trained adapter. It opens on a cafe counter and runs through an office desk, a roastery sack of beans, a city skyline at dusk, a kitchen, a cup conveyor and an espresso machine.

![The eight shots from the new adapter]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-bgfixed-shots.jpg)
*All eight shots. Location and lighting change every time while the coffee-bean robot keeps its proportions, its cyan eyes and its limb shapes. The seventh shot came out with a flat background and we left it in.*

The mascot is a fully synthetic character, and the six stills below are the only input any method received.

![Six mascot reference stills]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-refs.jpg)
*These six go in as the references.*

## The first commercial could not be made with this adapter

The hypothesis was that a non-face subject would neutralize the face-specific priors that zero-shot methods lean on, so training should win. We generated twelve mascot clips, trained for 400 steps, and ran four methods over the same eight prompts.

Read as a table, training looked fine.

| method | subject fidelity | worst frame | prompt following |
|---|---|---|---|
| baseline (unconditioned) | 0.461 | 0.410 | 0.381 |
| VACE zero-shot | 0.724 | 0.567 | 0.344 |
| Bernini zero-shot | 0.866 | 0.840 | 0.376 |
| trained LoRA | 0.839 | 0.760 | 0.350 |

Assembled, it looked like this.

<video controls muted playsinline style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/nubo-film-b-trained.mp4" type="video/mp4">
</video>

The mascot is perfectly consistent and the eight scenes are effectively one. The cafe counter, the sack of roastery beans and the studio lighting all became the same beige wall. It was unusable as a commercial, so at the time we shipped a zero-shot cut instead.

A subject fidelity of 0.839 says the mascot survived, not that the scene did. The metric measures the subject alone, so it is structurally incapable of seeing a background collapse. Prompt following barely reacted either, 0.350 against 0.344, because on a short prompt a matching subject term holds the score up even when everything behind it is gone.

## The culprit was the training data

One thing nagged.

![The twelve clips used for the first training run]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-trainset.jpg)
*Every clip that went into the first run. All twelve share the same beige studio backdrop.*

That was an inevitable consequence of deriving them from a single seed clip, and from the adapter's point of view "this mascot" and "this backdrop" may never have been separable.

So we reshot the same mascot in twelve places, a park bench, a library aisle, a beach at sunset, a snowy street at night, a subway platform, a greenhouse, a bakery display, and retrained. The reference stills were held identical index for index, and rank, learning rate, step count and seed were all fixed. Backgrounds were the only thing that moved.

![The same prompt generated three ways]({{ site.url }}{{ site.baseurl }}/assets/images/character-ad-film-b-bgfix.jpg)
*Every row is the same prompt with the same seed. Left is the first adapter, centre is the one retrained after changing only the backgrounds, right is zero-shot conditioning with no training.*

In the left column the office desk, the city skyline and the cup conveyor are all the same wall texture, while the centre column is the same training method with the scenes intact. The only difference between them is where the twelve training clips were shot.

The right column is worth a look too. The scenes come out fine, but in the first row the mascot is simply gone, leaving a laptop on a desk. In the third row the shape is there and the eyes are not.

## Confirmed in numbers

Measuring the collapse needed a metric. Its signature is that clips given *different* prompts come out looking alike, so we measured similarity between clips rather than distance from a reference, and cropped the centre out so the shared subject would not dominate. Before trusting it we checked it against arms whose answer we already knew by eye: the adapter that visibly collapsed scored highest at 0.906, and the unconditioned baseline lowest at 0.714.

| | background collapse | subject fidelity | worst frame |
|---|---|---|---|
| trained, one backdrop | 0.906 | 0.839 | 0.760 |
| **trained, varied backdrops** | **0.791** | **0.843** | **0.819** |
| zero-shot | 0.792 | 0.724 | 0.568 |

The new adapter lands at 0.791, level with zero-shot's 0.792. What matters is that the mascot survived: subject fidelity moved by 0.004, which is statistically nothing (p=0.67). This was not a trade of the character for the scenery; it simply stopped teaching the adapter that the backdrop was part of the character.

A second signal normalised alongside it. The collapsed adapter's clip-to-clip similarities had an unusually small spread of 0.022, meaning every pair was alike to the same degree, which is what convergence on a single background looks like. The retrained one sits at 0.060, in the same range as the other methods.

## The comparison at equal background diversity

Comparing again at equal background diversity even shows where training has the edge. At the point inside a clip where the subject degrades most, the trained arm reads 0.819 against zero-shot's 0.568, and that gap is significant (p=0.044). The first row of the figure above, where zero-shot drops the mascot entirely, is what that number is made of. The mean-fidelity gap of 0.843 against 0.724 is *not* significant across eight clips (p=0.16), so the claim available today is about the worst moments rather than the average.

## What this leaves us

When a metric is blind to an axis, the model that fails on that axis rises to first place. Had we picked a winner on subject fidelity alone we would have shipped the adapter that destroyed all eight scenes. The ranking only became legible once we added an axis that scores backgrounds and scene composition separately.

And what looks like a limit of a method is sometimes a property of the data. Shooting twelve clips in one location was convenience rather than design, and that convenience reached the model as a rule: this character lives in front of a beige wall. The smaller the training set, the more readily whatever the shots have in common becomes part of the character.

## The ThakiCloud angle

Mascot clip generation, the twelve-clip training run, the controlled four-way comparison, the retraining and re-measurement after changing backgrounds, and the 45-second assembly all closed inside internal GPUs. The character, a brand asset, never left for an external API. Maxis owns the phases that need training and Metis owns generation and serving.

What actually earned its keep here was not that some method won, but that a wrong conclusion could be tested against our own data and reversed. That the fix belonged in the data rather than the method is also something no amount of reasoning would have told us.

The numbers in this post are measured on internal GPUs, not simulated.

## References

- [VACE: All-in-One Video Creation and Editing](https://arxiv.org/abs/2503.07598): the zero-shot reference conditioning method in the comparison
- [Wan2.2](https://github.com/Wan-Video/Wan2.2): the open-weights video model used as the base
- [LoRA: Low-Rank Adaptation of Large Language Models](https://arxiv.org/abs/2106.09685): the trained adapter method
- [Previous post: Reimplementing a reference-conditioned video LoRA on internal GPUs](https://thakicloud.com/tech-blog/en/research/ref2va-reference-video-lora/): the LoRA training recipe and the controlled-comparison baseline
- [If Your Mascot's Eyes Look Alien, the Problem Is the Catchlight, Not the Colour](https://thakicloud.com/tech-blog/en/research/mascot-redesign-eyes-and-actions/): a follow-up in the same coffee-bean mascot series (eye redesign and reference-expression variety)
