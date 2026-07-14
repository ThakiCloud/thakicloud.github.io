---
title: "The Age of Steam Engines, Waiting for Carnot: The Mindset Science Needs Right Now"
excerpt: "The gap between a machine that works and a principle we understand is one of the oldest scenes in the history of science. In an era that solves everything with computing power, this essay rereads the deep learning age through the lens of energy and waves, and argues for a scientist's humility."
date: 2026-07-05
last_modified_at: 2026-07-05
lang: en
tags:
  - philosophy-of-science
  - deep-learning
  - thermodynamics
  - waves
  - research-culture
  - humility
author_profile: true
toc: true
toc_label: Contents
canonical_url: "https://thakicloud.github.io/en/culture/waiting-for-carnot/"
header:
  image: /assets/images/waiting-for-carnot-hero.webp
categories:
  - culture
---

![Abstract visual of steam and wave energy crossing into interference patterns](/assets/images/waiting-for-carnot-hero.webp)

## The 20-Watt Question

I have an old habit. Whenever I meet a phenomenon, I first try to rewrite it in the language of energy. Light and sound are both waves, and a wave is how energy crosses space. Communication is the art of loading information onto that energy, and software is the formal system that manipulates the information. Twenty-plus years of writing code never cured the habit. If anything, it deepened.

Look at today's artificial intelligence through that habit and one number sticks in your throat. The human brain runs on roughly 20 watts. On less power than an incandescent bulb, we learn languages and recognize faces. Occasionally we even imagine new theories of physics. Today's large models, by contrast, are trained in data centers that swallow the power of a small city. Two systems solving broadly similar problems, and the energy they spend differs by many orders of magnitude. Not one or two.

I do not read this gap as a performance problem. I read it as an understanding problem. A civilization that understands a task in principle does it with less and less energy over time. A civilization that only imitates the result pours energy into the gap. The very fact that we are imitating 20 watts with gigawatts strikes me as the most honest quantitative evidence that we do not yet know the principles of intelligence.

## The Half Century Before Carnot

We have been here before. The history of science has staged this scene more than once.

By the late eighteenth century, steam engines were already driving the mines and factories of Europe. Watt's engine was a commercial success, and engineers competed fiercely to build them bigger and finer. Yet nobody knew why the engines worked, or whether there was a fundamental limit to extracting work from heat. The machines ran. The theory did not exist.

Sadi Carnot published his paper in 1824, showing that every heat engine faces an efficiency ceiling set by temperature alone, a ceiling no engineering cleverness can break. That was half a century after steam power began transforming industry. And from that short paper grew the science of thermodynamics. Entropy emerged, energy conservation was formalized, and a long chain began that eventually reached statistical mechanics and information theory.

What I care about here is the order of events. The working machine came first. Understanding came later. And the real leap came not from the people who built bigger machines but from the person who asked why the machines worked at all. After Carnot, civilization no longer had to grow boilers indefinitely. It could compute the theoretical limit of efficiency and design its way toward it.

Deep learning today sits exactly where the steam engine sat before Carnot. The engines work magnificently. Industry is already being reorganized. But there is no thermodynamics of intelligence. Why does generalization emerge at this scale of data and parameters? What are the fundamental limits and minimum costs of the process we call learning? Like the engineers before Carnot, we know these things only as rules of thumb.

## Kelvin's Two Clouds

In April 1900, Lord Kelvin gave a lecture at the Royal Institution about two clouds hanging over the physics of his day. One was the failure to detect the Earth's motion through the ether, the medium then believed to carry light. The other was the inability of classical theory to explain the energy distribution of blackbody radiation. In the mood of the time, both looked like minor finishing work on a nearly completed building.

Out of those two clouds came relativity and quantum mechanics. The exceptions that looked trivial forced the whole building to be rebuilt.

The lesson usually drawn from this story is about the humility of prediction. I want to put the emphasis somewhere slightly different. There were eyes that recognized the clouds as clouds. Even in an age when everything seemed solved, some people refused to sweep the unexplained residue under the rug of minor error, and the next physics was born precisely from that residue.

Today's artificial intelligence has its own clouds. The empirical law that more scale brings more capability works well, but nothing explains why. Models often generalize surprisingly far beyond their training data, yet no theory predicts when generalization will collapse. The relation between producing plausible sentences and understanding the world remains fog. If you are drunk on the speed at which benchmark scores climb, these look like finishing work. To me they look like two clouds.

## The Achievement Called Scaling

I want to avoid a misunderstanding. I have no intention of belittling scaling.

Getting here by concentrating computing power is, by my standards, an achievement that belongs in the history of engineering. Distributed systems that bind tens of thousands of accelerators into a single training run, optimization methods that converge stably on top of them. This is precise engineering. Calling it brute force would be an insult to the engineers who built it. As someone who went around preaching that deep learning would matter long before it was fashionable, I confess that watching the prediction come true at this scale moves me.

The problem is not the achievement but the illusion it creates. While the scaling curve climbs, the curve itself starts to look like scientific progress. But making a stronger engine by enlarging the boiler and founding thermodynamics are different kinds of activity. The former executes a known method at greater scale. The latter asks why the method works and computes its limits. We need both. When only the former survives, a field prospers as engineering and stagnates as science.

One contrast strikes me. Over the same period, quantum computing and quantum information walked a different road. From the days when the hardware was still primitive, that field built its theory first: the limits of error correction, the quantification of entanglement as a resource, a complexity theory of which problems become easy quantumly and which do not. It is a rare case of understanding walking ahead of the machine. I suspect that ordering is exactly why the recent results coming out of that field look so solid.

## A Culture That Consumes Boxes

What worries me more than the technology is the culture.

For many researchers and engineers entering the field now, the model is a box. Input goes in, output comes out, and there is neither need nor courage to open it. A few lines of API calls produce products that were impossible yesterday, so opening the box looks like an inefficient hobby. Polishing prompts and refreshing leaderboards have become the default motions of research.

Abstraction itself is innocent. I climbed the same ladder from assembly through high-level languages and frameworks, and abstraction is where productivity comes from. Not everyone needs to understand transistors. But in the history of science, the leap to the next layer has always come from someone who climbed down below the abstraction boundary. Many people used steam engines as boxes; Carnot drew the flow of heat inside the box. Many people consumed wireless telegraphy as a marvelous box; Maxwell and Hertz read the wave equations inside it.

Using a box well and daring to open it are different muscles. Today's culture trains only the first one. Give it a generation and we may find ourselves in a field overflowing with people who can run the engines, with no one left who can found the thermodynamics.

## The People Who Changed Coordinates

So what should we do after opening the box? Let me pull one hint from the history of science. The great leaps came not from more computation but from a change of representation.

Fourier showed that any signal, however complex, can be rewritten as a sum of simple waves. The signal stays the same, but once the coordinates for viewing it change, structure invisible in the time domain becomes vivid in the frequency domain. All of modern communication and signal processing stands on that shift of perspective. Shannon rewrote communication from a problem of voltages and circuits into a problem of probability and entropy. Suddenly the theoretical ceiling on how much information a channel can carry became computable. When the representation changes, the limits become visible. When the limits are visible, you can design toward them.

As someone who has spent a career unfolding light and sound as waves, I confess that when I look inside neural networks, the language of waves keeps flickering at the edge of my vision. Representations overlapping and interfering in high-dimensional spaces, components filtered and amplified as they pass through layers. I do not know whether this is the right language. Perhaps entirely different mathematics is needed. I make no claim that waves are the answer. But I find it hard to shake the suspicion that what we need now is less a bigger cluster than a new coordinate system. Structure that will never appear in the coordinates of loss curves and benchmark scores may fall out as a single inequality in some other representation.

## Living Before the Thermodynamics of Intelligence

Which brings us back to the opening question. In a time like this, what mindset should a scientist hold?

The first thing I would name is humility. Not the etiquette of lowering yourself. The accuracy of your perception. Admitting plainly that we own a working engine but not a theory. Refusing to mistake rising benchmark scores for growing understanding. Keeping the gap between 20 watts and gigawatts at the top of the homework list. That much is enough.

Next is the discipline of staring at clouds. Industry will take care of making what works work better. The scientist's job is to face the unexplained residue instead of filing it under minor error. Why does it generalize? When does it break? Questions like these do nothing for next quarter's earnings, and the science of the next half century will be born exactly there.

A habit of doubting the representation also helps. The coordinate system we use now is not the only one. Signals existed before Fourier and communication existed before Shannon. What was missing was the language to rewrite them. Practicing rewriting your own field in an alien language, borrowing mathematics from a neighboring discipline. Most such attempts fail, and the one that succeeds changes the sky over the whole field.

Let me add one last thing. This is not a time for discouragement. The physics students of 1900 were lucky. They were born into an age that believed the building was finished, and they became the generation that rebuilt it. That there is no thermodynamics of intelligence means the site for it is vacant. The history of science rarely sends a more thrilling invitation.

## To the Next Carnot

ThakiCloud builds GPU clusters and AI platforms. You could say our trade is building the boilers of this era. Which is exactly why we keep telling ourselves that boilers are not the whole story. Infrastructure does not ask the questions for you. Good infrastructure only lets a person with good questions experiment faster and at lower cost. Our obsession with platform efficiency and energy cost returns, in the end, to the same place: measured against the standard set by a 20-watt brain, today's computing still has a great deal to be humble about.

The age of steam engines waited for Carnot, and the waiting was not in vain. Somewhere right now, someone is prying open the box, asking about principles instead of benchmarks, perhaps still a student. I hope this essay reaches that next Carnot as a small cheer. The engines are already running. What we need now is the courage to ask why they work.

## References

- [Sadi Carnot, Reflections on the Motive Power of Fire (1824), the starting point of thermodynamics](https://en.wikipedia.org/wiki/Reflections_on_the_Motive_Power_of_Fire)
- [Lord Kelvin's 1900 "two clouds" lecture](https://en.wikipedia.org/wiki/Lord_Kelvin)
- [Claude Shannon, A Mathematical Theory of Communication (1948), original text](https://people.math.harvard.edu/~ctm/home/text/others/shannon/entropy/entropy.pdf)
- [Fourier series: representing signals as sums of waves](https://en.wikipedia.org/wiki/Fourier_series)
- [The human brain runs on roughly 20 watts](https://hypertextbook.com/facts/2001/JacquelineLing.shtml)
