---
title: "If your character comes back as a different character every time, more reference images will not fix it"
excerpt: "We gave the model four reference stills and asked for the same character. The base model scored between 0.35 and 0.43 CLIP-I no matter which character it was. An adapter took that to 0.76, and editing from a reference took it to 0.82."
categories:
  - research
tags:
  - character-consistency
  - reference-conditioning
  - lora
  - image-editing
  - evaluation
  - clip-i
author_profile: true
toc: true
toc_label: "Contents"
header:
  teaser: /assets/images/character-identity-hero.png
---

![Character identity](/assets/images/character-identity-hero.png)
*One form that still reads as the same form after every transformation. That is the problem a character pipeline actually solves.*

Anyone who has put a mascot through a generation pipeline knows the moment. The front render came out well, and then you ask for the same character in twelve poses and get twelve different animals back. The colours are roughly right and the mood is close, but you would not call it the same character.

The obvious fix is to add more reference images. We tried that, and the result was not what we expected. This post is the numbers from eight characters and what those numbers did to our pipeline design. The short version: identity is not something you instruct through a prompt. You put it into weights or into pixels.

## The base model does not draw your character, even with references

The setup is simple. For each character we conditioned on four reference stills and asked for **six actions the model had never been trained on**. That the holdout actions do not overlap the training set is asserted by code rather than checked by eye, because replaying a trained action measures memorisation, not generalisation.

Both arms share the prompt, the seed and the references. The only difference is whether the adapter is loaded. The score is CLIP-I: cosine similarity between the image embedding of a generated frame and that of the references. Mascots often have no face, which rules out ArcFace-style face metrics, and CLIP-I is what takes their place.

![A/B results](/assets/images/character-identity-ab-results.png)
*Five characters, six unseen actions each. Grey is the base model, blue is the adapter.*

The adapter beat the base model on all five, and on twenty-eight of thirty clips. But the interesting part of that chart is the grey bars, not the blue ones.

| Character | Adapter | Base | Delta |
|---|---|---|---|
| metis | 0.762 | 0.427 | +78.3% |
| velox | 0.712 | 0.362 | +96.8% |
| dodam | 0.653 | 0.366 | +78.4% |
| aegis | 0.457 | 0.365 | +25.4% |
| haram | 0.419 | 0.353 | +18.5% |

**The base model lands between 0.353 and 0.427 regardless of the character.** A teardrop, a winged triangle, a box on treads: the score barely moves. Four reference stills faithfully passed in as conditioning, and the model still returns to its own average instead of drawing your character. References carry mood. They do not carry identity.

This matters because it is exactly the direction most teams push when a character drifts. Six references instead of four, a longer description in the prompt, more seeds to choose from. A flat grey bar says that direction has a ceiling.

## Tightening the prompt moved nothing

Before accepting that, we pushed on the prompt side first. We measured self-consistency, meaning how closely repeated renders of one character resemble each other, and layered three interventions. Lower is more consistent.

| Intervention | Quadruped character | Six-limbed star |
|---|---|---|
| Baseline (12 seeds) | 0.337 | 0.191 |
| Seeds raised to 32 | 0.315 | 0.223 |
| Species and limb count pinned | 0.305 | 0.244 |
| Pose fixed to front | **0.154** | 0.210 |

Nearly tripling the seed count left the variance where it was. When a larger sample does not shrink the spread, the spread is not coming from sampling. Writing "a four-legged big-cat creature, body twice as long as it is tall, short muzzle, not a dog, not a lizard, not a dinosaur" moved 0.315 to 0.305 and no further.

The only intervention that moved anything was fixing the pose, and that turned out to be a finding about our metric rather than about the character. **The measurement was conflating pose with identity.** A quadruped seen from a different angle has a completely different silhouette. The bipedal front-facing characters never had this problem because they had no pose freedom to begin with.

Two practical lessons came out of it. Reference and evaluation renders should be produced in a fixed pose, or pose variance gets read as identity failure. And identity is not something a prompt delivers, which is why we trained adapters at all.

## Editing holds identity considerably better

Training was not the only answer. Conditioning on a reference image and **changing only the action** scored higher than either.

We anchored on a single front render and wrote nothing about identity in the prompt. The instruction was only "keep the character exactly as in the reference, change the pose", across ten actions from waving to back view to sitting, for 160 images. The result was CLIP-I **0.823**.

| Path | CLIP-I | What it produces |
|---|---|---|
| Reference edit | 0.823 | Stills |
| Trained adapter | 0.42 to 0.76 | 81-frame video |
| Base model | 0.35 to 0.43 | 81-frame video |
| Reference self-similarity | 0.96 | Ceiling of the metric |

These sit on the same scale but they are different tasks. One edits a single still, the other generates 81 frames. Subtracting one from the other would be wrong. On the identity axis alone, though, editing is clearly ahead, and that gap changed our design.

Editing holds identity and the adapter handles video. They are not competitors, they divide the work. Render the front character once, derive expressions and poses and viewpoints through editing, and spend the adapter only on what editing cannot do, which is video and temporal coherence.

```mermaid
flowchart TB
    A["One front render<br/>text to image"] --> B["Derive by editing<br/>expression, pose, view"]
    B --> C["Pick 4 references<br/>by representativeness"]
    C --> D["12 action clips<br/>reference to video"]
    D --> E["Train adapter<br/>LoRA"]
    E --> F{"Holdout A/B<br/>does it beat base"}
    F -->|wins| G["Register in catalog"]
    F -->|loses| H["Not registered"]
    B -.identity 0.823.-> B
    E -.identity 0.42-0.76.-> E
```

## Colour is not instructable in hex

Identity is not only a question of form. We measured colour drift alongside it, and the cause was not where we looked first.

Per-character palette adherence put two characters in the twenties on both models. That looked like a model problem until we noticed those two were also the two characters with **dark palettes**. Shading pushes a dark colour further in colour space than a light one, which gave us reason to suspect the metric before suspecting the specs.

Changing the metric to compare hue while ignoring lightness split them apart. One went from 22% to 99.7%, the other from 23% to 26.5%. The first was the metric penalising darkness. The second was a real hue departure.

The real one traced back to how the prompt was passing colour.

```text
#24305E is the dominant colour covering the largest share of the body;
#0C1330 is secondary; #8FA3D6 only as small trim.
```

To a text-to-image model a hex code is not a colour instruction. It is a token that occasionally rhymes with one. The characters that passed did so because their palettes sat near a common colour word, and the one that failed produced green and red variants.

Translating hex into words took that character from 26.5% to 43.5%. Better by 1.6x and still under half, and the remainder was the palette itself: the primary and secondary differed by **0.7 degrees of hue**, which is the same colour at two brightnesses. Given nothing to distinguish, the model picks its own.

Two rules came out of this. Pass colour as words and keep the hex as a trailing anchor. And detect palette collisions by **hue angle rather than by string**, because our first version compared phrases and let "dark blue" and "very dark blue" through as different colours.

## Complex forms shake under editing too

Editing is not universal. The per-character spread is wide.

The character with a tall conical crest scored 0.878, the floating and quadruped forms sat in the low 0.82s, and **the one whose six limbs radiate outward as a star dropped to 0.651**. The six lowest-scoring actions in the whole set all belonged to that character, because editing keeps changing the number and angle of its limbs.

The same character had the worst self-consistency in text generation as well, which points in one direction. **The more degrees of freedom a form has, the more it shakes on any path.** A countable property like limb count, left open in the prompt as "six or more", produces a different count every time.

It is easy to check only whether silhouettes are distinguishable when designing a cast. Just as important is **how many degrees of freedom each form carries**. Forms with few reproduce well on any tool, and forms with many shake on any tool.

Widening this to the whole cast produced something less comfortable. We put eight candidate forms on four characters, eight seeds each, and compared them with the colour stripped out. **Only five of the eight were distinguishable.** The other three all collapsed into the same humanoid.

More importantly, the product axis did nothing. Putting the same form on different products produced nearly identical images row for row. Even the eagle archetype came back as the same humanoid and the same heavy blob. **The product description in a prompt reaches texture and ornament, but it does not reach form.**

So we generated twelve more candidate forms and eleven of them separated. The ones that passed share a property. Limbs radiating out like a star, a flat base instead of legs, no legs at all with a gap above the shadow, a body flattened into a diamond. All of them change the **outline**.

A hole through the belly, by contrast, was vivid on the contact sheet and vanished in the silhouette, because an interior hole leaves the outline untouched. Calling that sheet a silhouette judgement was our mistake.

One more thing. Surface treatment is not an identity axis. Hand-painted, clay or flat vector all disappear the moment colour does. That is why our eight characters were each assigned a different skeleton. Two characters sharing a skeleton with different surfaces are one character once you strip the colour.

## Thresholds belong on top of measured noise

While measuring how well characters separate from each other, we set the threshold at 0.18. There was no basis for it, and anything below counted as the same character. Only later did we measure **the distance between seeds of the same character**.

Within one character the median distance between seeds was 0.102, and the worst character reached 0.337. The smallest distance between two different characters was 0.114. **The two distributions overlap.** The quadruped was further from itself than any two different characters were from each other. Every verdict at 0.114 had been measuring noise rather than signal.

The order of the questions was wrong. **"Are these two different" comes after "is this the same thing twice".** A character whose own variance is high is not eligible for comparison at all. We reordered the gate and now exclude high-variance characters from pairwise comparison entirely.

If you are building a metric with a threshold, we would suggest this order. Measure the variance of repeating the same condition first, then set the threshold above it. Done the other way around, a single constant quietly decides the conclusion of the whole experiment.

## Conditioning can fail silently and the job still succeeds

We threw away two A/B runs before reaching any of this. The cause was neither the model nor the data.

In reference-conditioned sampling, a reference that fails to attach does not fail the job. One warning line goes into the log and everything else completes normally.

```
[refs] h6: 0 stills []
[refs] WARNING h6 has no reference stills in . — that clip will render unconditioned
[gen 1/6] h1 -> h1.mp4 (81f, refs=0, ..., 224.4s)
...
VERDICT: GO
```

All six clips rendered unconditioned, the job reported `GO`, and the outputs looked fine. Scoring that would have compared an adapter and a base model both drawing without conditioning, and the conclusion would have been **the exact opposite: that training does not help**. We nearly read it that way twice.

The cause had two layers. References resolve per persona, and our slug prefix was being taken as the persona so it never matched the filenames. The reference directory path was also wrong. Both values were spelled out in the existing launch script. Reading it and not following it was the actual failure.

So the check moved out of human memory and into the pipeline. Immediately before scoring, it reads the attachment evidence from the log and **refuses to score** any arm that rendered with zero references.

```python
def refs_attached(run: str) -> bool | None:
    """What the log says about attachment. None means unknown, not a pass."""
    log = pod_logs(run)
    for line in log.splitlines():
        if line.startswith("[refs]") and "stills" in line:
            n = line.split(":")[1].strip().split()[0]
            return n.isdigit() and int(n) > 0
    return None
```

Generalised: **conditioning inputs fail quietly.** Reference images, masks, ControlNet hints, injected system prompt fragments, all of them. A pipeline that uses them has to verify attachment from the log rather than from the output, and that verification belongs somewhere automated.

## What to take into your own pipeline

The first thing to do is measure your base floor. If you do not know what the base model scores when handed references and asked for the character, you do not know how much improvement you need. Ours was 0.35 to 0.43, and that single number justified spending GPU on training. Had it already been 0.8, there would have been no reason to train.

Evaluate only on actions that were not trained. Replaying a trained action is memorisation rather than generalisation, and the difference shows up directly in the score. Confirming non-overlap by eye works until the day it does not, so we made the holdout builder assert that the intersection with the training set is empty.

When choosing a metric, look first at what the experiment was designed to vary. Measuring silhouette distance in an experiment where the action changes reads the experimental design itself as a failure. We made this mistake on two consecutive days: we wrote down that silhouettes conflate pose with identity, and then measured our edits with it the next morning.

Use different tools for stills and for video. Editing holds identity, the adapter owns the temporal axis, and trying to do both with one of them leaves both mediocre.

Finally, verify conditioning attachment from the log, and put that check in the pipeline rather than in a person. Left to memory it gets missed, and the conclusion that follows a miss is not merely wrong, it points in exactly the opposite direction.

## How this runs at ThakiCloud

All of this ran on our own B200 cluster. Image generation, editing, video generation, LoRA training and evaluation all finish inside the same environment with no external API. Clip generation and adapter training for eight characters ran in parallel within a day because the jobs could simply be pushed into the GPU queue.

Model weights are pulled from internal object storage over the internal network. We measure roughly 1GB per second into a pod, against about 6MB per second for the same file from outside. For a pipeline where a 53GB editing model has to be fetched for every job, that difference decides whether the experiment is possible at all.

Trained adapters are registered in the model catalog so the next serving run can use them directly. We register **only the adapters that beat their base in the A/B**, because a catalog listing four losers next to one winner cannot answer which one to serve. That judgement is made by a code gate at registration time, not by a person.

Metis is the inference and serving layer and Maxis is the training and evaluation layer, and work like this, running from generation through training to evaluation in one flow, is what exposes the seams between them. Nearly every problem we hit this time lived in a seam rather than in a model.

## Open questions

The size of the adapter's gain varied a lot by character. The teardrop form gained 97% and the conical crest gained 19%. The natural reading is that a form the base already handles leaves less for an adapter to add, but a correlation across five characters cannot explain the ordering. We will look again with more characters.

We also do not know the ceiling on editing. The 0.823 sits some distance below the reference self-similarity of 0.96, and we have not separated whether that gap is a limit of editing or a limit of our prompts.

If you are hitting the same problem, we would suggest starting by measuring your base floor. It took seeing that number for us to know what needed fixing.
