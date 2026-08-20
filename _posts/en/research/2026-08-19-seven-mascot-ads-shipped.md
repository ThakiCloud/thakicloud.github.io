---
title: "Seven mascot ads: the films we actually shipped"
excerpt: "One brand film and seven per-product ads. No training involved, just four character stills and one gray cutout video made with Python."
categories:
  - research
tags:
  - video-generation
  - character-consistency
  - ad-production
  - mascot
author_profile: true
toc: true
toc_label: "Contents"
header:
  teaser: /assets/images/cf-seven-ads.jpg
canonical_url: "https://thakicloud.com/tech-blog/en/research/seven-mascot-ads-shipped/"
audiobook: "https://drive.google.com/file/d/15EgjwsldC5WlQlrUxNh8yKR-JkSX4Hgz/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

This post is for anyone curious what an ad campaign built around a mascot actually looks like when
it ships. The method is written up in [the previous post](/tech-blog/en/research/mascot-ad-stills-vs-storyboard/),
and here we lay out the finished results as they are: one brand film and seven per-product ads,
with no per-character training.

![Illustration of the core idea of Seven mascot ads: the films we actually shipped](/assets/images/seven-mascot-ads-shipped-hero.webp)
*A visual metaphor for the article's key idea.*

## First, all seven products in one film

A 25-second brand film. It opens in an empty glass atrium, then each of the seven mascots takes
one beat in its own world.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-brand-film-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-brand-film.mp4" type="video/mp4">
</video>

![Brand film, eight shots]({{ site.url }}{{ site.baseurl }}/assets/images/cf-brand-film-shots.jpg)
*Eight shots. The world changes every time, and each character stays itself.*

This film was made differently from the other seven. On top of conditioning on the character, we
also fed in a **motion video** showing how the character should move. That video is a gray
cutout, made by scaling and stretching one reference still with Python. No background, no props,
just a moving silhouette. The model built the entire world on its own.

How we arrived at this method, and the numbers that came out of it, are written up later in this
post.

## Seven per-product ads

Each is 42 seconds.

## Paxis

A work automation product. It opens on a shaking starship bridge, red alerts flaring across every
console.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-paxis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-paxis.mp4" type="video/mp4">
</video>

## Metis

A product that handles inference and tokens, so we set its world as a factory line. Bottling
conveyors and steam carry the metaphor.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-metis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-metis.mp4" type="video/mp4">
</video>

## Maxis

A product that grows models. We went with a jungle, clearing vines and letting a shoot break
through.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-maxis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-maxis.mp4" type="video/mp4">
</video>

## Telox

A product that hauls GPUs, so we used a steam locomotive and rail line as its world.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-telox-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-telox.mp4" type="video/mp4">
</video>

## Velox

The theme is speed with virtualization stripped away. It runs across a storm-lashed pier.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-velox-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-velox.mp4" type="video/mp4">
</video>

## Aegis

A product that holds the line inside a closed network. We drew it as a vault that doesn't retreat,
standing in a burning field.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-aegis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-aegis.mp4" type="video/mp4">
</video>

## Signum

A product that asks for identity first, so we set its world as a night alley.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-signum-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-signum.mp4" type="video/mp4">
</video>

## Which method built which

The seven films weren't made the same way. We chose between conditioning on character stills and
conditioning on a storyboard sheet for each product, but we set the selection rule first and let
the rule decide. Fewer cuts wins, unless identity gaps by more than 0.05, in which case that flips
the choice.

Identity averages sit close together at 0.636 versus 0.617, while cut count spreads apart at a
median of 15 versus 5, so we let the axis that actually diverges make the call and put a high
threshold on the axis that doesn't. Running the rule sent five films to storyboard and two to
stills. The reasons for the two that stayed with stills are clear. Metis was the one exception
where storyboard cuts spiked to 26, and Telox crossed the threshold with an identity gap of 0.063.

![Final seven films]({{ site.url }}{{ site.baseurl }}/assets/images/cf-seven-ads.jpg)
*The seven films laid out in one frame. Each world differs by product, and each character stays itself.*

## What we fixed along the way

**Resolution default.** The first films we generated were visibly blurry, and the cause was a
generation resolution stuck at 832x480. That was the script's default and nobody had raised it.
Switching to 1280x720 pushed bitrate from 0.41 Mbps to 3.0 Mbps. On top of that, three stacked
re-encodes were cutting quality further. Now intermediate stages stay near-lossless and
compression happens only once, at the end.

**End-card clipping.** We once drew the card carrying the product name and slogan at 877 pixels on
an 832-pixel canvas. We'd calculated the width and never checked it. Now the card is rendered at
the same resolution as the video, text shrinks when it crosses the safe area, and an exception is
raised if it doesn't fit at any size. Code that calculates a width has to carry the check for that
width too.

**Clipped training clips.** This project once threw away eight full adapters. Of the 48 training
clips, 38 had the character clipped outside the frame, and one character was clipped in all twelve
of its clips. Yet every metric passed. That's because the metric was asking whether the clips were
consistent, and nobody was asking whether they were usable. When clipped clips are consistent with
each other, the consistency score actually goes up.

## No training was involved

None of the seven films involve any per-character training. Four stills or one sheet is all it
takes, and even the sound is generated by the model. The biggest difference from a training-based
path is that there's no prep time.

We also have results from training an adapter on the same character for 400 steps, which scored
0.560 on identity. In a later experiment, the training-free motion-instruction method scored 0.704
on the same character, same evaluator, same reference. The prompt sets differ, so it isn't a
controlled comparison, but the direction reads clearly: instructing only what to draw is cheaper
than re-teaching a large video model something it already knows.

## Remaining limits

CLIP-I, the identity metric we used, looks at the whole frame, so scores rise when backgrounds are
similar, and they don't drop much even when a character's form breaks down as long as color and
silhouette remain. It's usable for relative comparison, but it shouldn't be read as absolute
quality.

And this method still has a narrow vocabulary of motion. Right now only two actions land reliably,
approaching and leaping, while subtler motion like a slow frontal push-in gets ignored by the
model. Carrying a full ad needs a bigger vocabulary. That's the next piece of work.

## How the motion-video method came about

The method used in the brand film came out of three failures. There was already a path for
conditioning on a video of the character moving, and all three tries came out looking like a flat
cartoon, with the original background showing straight through. We wrote it down as an axis this
stack couldn't do.

That judgment was wrong. The pipeline has a value that sets the strength of that condition, and we
hadn't touched it in any of the three tries. The default sat at maximum, and at maximum the model
blacks out everything outside the instructed region. What we'd read as background leaking through
was actually a frame where the world had been erased. Lowering the strength to 0.6 got the model
to follow the instruction and build the world at the same time.

The next thing to confirm was whether this method plays favorites among characters. We picked four
with different skeletons and ran two actions on each: a rounded teardrop, a pointed star, a
wheeled box, and a flat kite. All eight films held identity, averaging 0.715 with a floor of
0.670. The same motion carried across bodies that share no skeleton.

One more place we were nearly wrong. In four of those eight films, part of the frame went dark,
and we almost read that as the approaching action emptying the frame. But leaping had been run in
a bright greenhouse and approaching in a dark night street, which meant motion and scene had both
changed at once. Filling in the two missing cells split the answer apart. Motion contributed
nothing to the dark frames (12.4 versus 12.3), and scene was everything (0.0 for day versus 24.7
for night). All eight bright-scene cells came out at exactly zero.

That's why all eight worlds in the brand film were set in broad daylight.

## Five times the metric disagreed with our eyes

The trap we hit most often in this work wasn't the model, it was the metric.

The identity metric looks at the whole-frame embedding, so it doesn't drop much even when color is
wrong. In one brand-film render, Paxis came out dark brown instead of orange, and that film's
identity score was a healthy 0.731 anyway. We caught it by directly measuring the RGB at the
character's center against the reference. The render came in at (99, 52, 22), the reference at
(236, 137, 23), a distance of 161. We had ordered a cold blue-white atrium, and the orange had
shifted to follow that light; switching to warm afternoon sunlight closed the distance to 90.

We also tried measuring vertical position to check whether it tracked a jump. Because the method
picks the background by the most common brightness, it grabbed the greenhouse plants as the
subject, and reported a film that was clearly jumping as barely moving. We only found out by
laying the frames out and looking.

**When an automatic metric disagrees with your eyes, it's usually measuring something else.**
Trust the metric and move on in that moment, and the wrong conclusion ships as is.

## References

- [DreamBooth: Fine Tuning Text-to-Image Diffusion Models for Subject-Driven Generation](https://arxiv.org/abs/2208.12242): the paper that defines CLIP-I, the metric that measures identity as cosine similarity between the CLIP embeddings of a generated image and a reference image.
