---
title: "We Built a Brand Sound System on One GPU: $0.007 a Song, and a 12.7x Gap That Came From the Execution Stack"
excerpt: "If you are weighing whether to serve a music model in-house, look at the execution stack before you look at the model. Same B200, same weights, different execution path, and throughput went from 36 songs an hour to 463. At $0.007 a song we built the whole sonic identity, including the ad film, in a day."
seo_title: "Serving a music model, measured: a 12.7x throughput gap and $0.007 per song"
seo_description: "MiniMax-Music3 measured on a single B200. Reference pipeline 36 songs/hour, serving stack 463. VRAM is pinned at 24.5GB regardless of song length and idle draw alone is 239W. Also why a sonic logo should be synthesised in code rather than generated."
date: 2026-08-15
last_modified_at: 2026-08-15
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "music"
tags:
  - music-generation
  - inference-serving
  - sonic-branding
  - throughput-benchmark
  - power-measurement
  - multimodal
  - gpu-serving
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/sonic-branding-generative-music/"
---

If you are deciding whether to bring a music generation model in-house, the question that
matters more than which model you pick is **how you run it**. We put the same weights on the
same B200, changed only the execution path, and throughput moved from **36 songs an hour to
463, a 12.7x gap**. The hardware did not change. The model did not change.

That put the cost of one song at **$0.007**. Sonic branding is normally a six-figure
engagement. Under a cent a song, you can build an entire brand sound system in a day and
rebuild it if you dislike it. We did exactly that, and you can listen to the result below.

## What we loaded, and where

MiniMax-Music3 is an open-weights model that takes lyrics and a structured caption and returns
a full 32kHz stereo song. It is a Global LLM of 8B, a Local LLM of 0.6B, a 2.4B Flow Matching
module and a 123M Flow-VAE, 57.35GB of weights in total.

The first obstacle was simply getting it onto the cluster. Measuring the same file across
different paths split them wide open.

| Path | Speed | For 57.35GB |
|---|---:|---:|
| GPU pod to HuggingFace | 5.9 MB/s | 162 min |
| Office Mac, official download client | 2.1 MB/s | 7 hours |
| Office Mac, parallel HTTP | 48.0 MB/s | 19.9 min |
| GPU pod to internal object storage | 753 to 873 MB/s | 66 to 78 s |

The internal network is 128 times the cluster's external egress, which settles the ingest path.
Fetch on a workstation, stage it internally, and every later job pulls over the internal
network. The first job already pays it back, and after that any experiment has the model in
75 seconds.

The official download client being 24 times slower than parallel curl is worth recording. That
client now routes through the Xet transfer path, and a plain single-stream curl on the same
file from the same host still managed 43.8 MB/s. The bottleneck was the transfer layer, not the
network. That is an observation at one point in time rather than a law, so measure it yourself
before a large pull.

## The 12.7x came from the execution stack

The reference path the model card documents calls the diffusers pipeline directly. On that path
a single 60-second song took 86 seconds to produce, slower than real time.

One measurement stood out. **Peak VRAM was pinned at 24.5GB regardless of song length.** A
30-second song and a 240-second song used the same. The B200 has 191.5GB, so 87% of the card
was idle. If the bottleneck is latency rather than memory, adding processes should multiply
throughput.

| Concurrency | Songs/hour | Scaling | GPU util | Energy per song |
|---:|---:|---:|---:|---:|
| 1 | 36.4 | 1.00x | 22.7% | 28,753 J |
| 2 | 72.5 | 1.99x | 46.3% | 17,084 J |
| 4 | 109.9 | 3.02x | 71.5% | 13,037 J |

Two-way is essentially linear and four-way bends to 3.02x. The column worth staring at is the
last one: energy per song improves **2.2x**. We only understood why after measuring power.

Then we put the same weights behind a serving engine. The model's own end-to-end test script
turns out to be an HTTP client hitting an OpenAI-compatible `/v1/audio/speech` endpoint, which
is itself a statement about the shape this model is meant to be deployed in.

| Concurrent requests | p50 latency | Songs/hour | RTF |
|---:|---:|---:|---:|
| 1 | 24.3s | 148.2 | 0.597 |
| 2 | 20.3s | 355.4 | 0.592 |
| 4 | 29.9s | 463.2 | 0.737 |

Even at a single request the real-time factor is 0.597, faster than real time. Against the
reference path's 1.62 that is 2.7x, and once concurrency is added it becomes the difference
between 36 and 463 songs an hour.

Same card, same weights. Every bit of that difference came from the execution stack. If you
evaluate a new multimodal model only to the point of "does it run on our GPUs", you leave this
entire factor on the table.

## What the power numbers taught us

We measured idle twice: before the model was loaded and after.

| Moment | Idle draw | VRAM |
|---|---:|---:|
| Cold, no model loaded | 187 W | 4 MiB |
| Model resident | 239 W | 23,484 MiB |

Weights merely sitting in VRAM cost **52W**. The true idle of a serving endpoint is 239W rather
than 187W, and if you rent the whole GPU you pay that 52W yourself.

This explains the concurrency table. Energy per song improved 2.2x not because the model became
more efficient but because **several songs began sharing that 239W floor**. Raising throughput
is, before it is a cost question, a question of converting power you already pay for into work.

When you quote power figures, say when the idle baseline was taken. Measure it right after a
load and the marginal figure comes out far too small, and any energy-per-song number built on
it is off by multiples.

## What did not reproduce

The model card advertises full songs up to five minutes. That did not reproduce for us.

| Requested | Actually produced |
|---:|---:|
| 30s | 35.9s |
| 60s | 66.1s |
| 120s | 92.1s |
| 240s | 138.3s |

Short requests overshoot and long ones fall short. The longest we ever got was 138.3 seconds.
`audio_duration` behaves as a hint rather than an instruction. The card does say that section
tags and captions offer generative control rather than symbolic guarantees, and this table is
what that sentence means in practice.

If length matters for your deliverable, this model alone will not do it and the render stage
has to fill with crossfaded loops. The ad film below was built exactly that way.

## Why a sonic logo should not be generated

Look across sonic branding work and a common structure appears. Netflix's "ta-dum", Intel's five
notes and Mastercard's payment sound all treat **a single two-to-five second mnemonic** as the
highest-value asset and build an arrangement system on top of it. It is also worth noting that
when Netflix made theirs, they deliberately rejected sounds that felt "too techy, like a
startup" and "too gamey".

But the mnemonic itself should not come from a generative model, for a simple reason.
**A logo has to be identical every time for recognition to accumulate.** The same three notes in
the same timbre at the end of an ad, at product boot, at an event opening. A generative model
drifts across versions even with a fixed seed, and more importantly you cannot demand
"exactly this frequency" from it.

So we split ownership. **Code owns the mnemonic, the model owns the arrangements.**

The motif is B♭3, F4, B♭4: root, perfect fifth, octave, straight off the harmonic series. Three
notes that are physically as fundamental as it gets, stacked, which makes an infrastructure
company's stack audible. The timbre starts as a wooden mallet and blooms into a sine, which we
chose as the sound of human work handing over to precise automation.

<p><audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-full.mp3"></audio></p>

numpy produces that file. The inharmonic partial ratios, the attack length, the procedural
reverb are all written down as numbers, and running it again yields identical bytes.

## The same three notes, seven arrangements

Our brand message is "One Paxis. Many Workflows. Any Cloud." One agent platform that flows
differently per workflow. The sonic architecture ought to have the same shape.

So all seven products **use the same three notes and differ only in partials, reverb and
foundation.** Played back to back they read as one piece wearing different faces.

<p>Paxis, agent automation. The reference statement.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-paxis.mp3"></audio></p>

<p>Metis, inference. Bright, decaying fast. Something answers immediately.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-metis.mp3"></audio></p>

<p>Maxis, training. Darker, accumulating slowly. Work that takes time.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-maxis.mp3"></audio></p>

<p>Velox, bare metal. Metallic, almost no reverb. A direct connection with nothing in between.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-velox.mp3"></audio></p>

<p>Aegis, on-premises. Low and solid. Inside a closed space.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/logo-aegis.mp3"></audio></p>

## The part the model made

Arrangements went to the model. The caption states the motif in words: a marimba states a
three-note rising figure of root, fifth and octave and repeats it throughout. The rest specifies
tempo, key, instrumentation and emotional progression per use.

<p>Main ad bed. 96 BPM, opening sparse and arriving wide at the two-thirds mark.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-ad-main.mp3"></audio></p>

<p>Metis product film. 112 BPM, immediate from the first bar with no build.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-product-metis.mp3"></audio></p>

<p>Maxis product film. 88 BPM, starting nearly empty and layering one element at a time.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-product-maxis.mp3"></audio></p>

<p>Aegis product film. 84 BPM, almost no high frequencies, low and solid.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/brand-product-aegis.mp3"></audio></p>

No caption ever names a living artist. They describe genre, BPM, instruments and texture and
nothing else. That is a practical constraint rather than a matter of taste. An AI-generated
track that reached 13 million Spotify streams was pulled from every platform because it
resembled a particular singer's voice. Imitate a voice and the asset becomes one that can
disappear at any time.

## All the way to the film

Making music and stopping there is not an ad. We built a 54-second brand film from these assets.

<video controls preload="metadata" playsinline style="width:100%;border-radius:12px">
  <source src="/assets/video/posts/sonic-branding-generative-music/brand-ad.mp4" type="video/mp4">
</video>

The sound that opens and closes it is the sonic logo built in code; everything between is the
model's music, crossfaded together. The on-screen text, shapes and timing were baked frame by
frame in Python and assembled by ffmpeg. No video editing tool was involved.

The length problem shows up here. The ad bed we requested at 60 seconds came back at 22, so the
builder loops it with one-second crossfades to fill 47 seconds. The render stage absorbs the
model's limitation.

Vocal songs work too. Everything for the brand is instrumental, but the model itself writes
songs with lyrics.

<p>Korean ballad. 84 BPM.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/hello-ko-60s.mp3"></audio></p>

<p>Korean trot crossed with Memphis phonk. 138 BPM.<br>
<audio controls preload="none" src="/assets/audio/posts/sonic-branding-generative-music/viral-02-trot-phonk.mp3"></audio></p>

## The ThakiCloud view

Here is how this measurement attaches to our products.

**For Metis, music is not a new axis but the same one.** We have talked about token factory
economics in terms of text inference, and this measurement shows the same structure holds for
multimodal. Getting 12.7x out of the same GPU by changing the execution stack, amortising an
idle power floor with concurrency, converting headroom above peak VRAM into throughput: these
are exactly the moves we already make in LLM serving. Putting a music generation endpoint in
the catalogue is not building new infrastructure. It is one more model on infrastructure that
already exists.

**The ingest path is an asset the platform should already own.** In an environment where
external egress runs at 5.9MB/s, fetching a 57GB model per experiment attaches 162 minutes to
each one. Stage it once in an internal registry and it becomes 75 seconds. This is not specific
to one model but a cost that recurs with every new release, and any organisation running its
own GPUs should hold that path as tooling. We keep a parallel HTTP fetcher, a multipart
uploader and catalogue registration fixed in scripts.

**From the Paxis view the whole thing is one workflow.** Model ingest, preflight gates,
generation, artifact retrieval, render, pre-deploy verification. Leave those scattered as steps
that need a human standing over them and a single brand sound takes days. In this work the
humans decided two things, which three notes the motif should be and which outputs to ship, and
a pipeline did the rest. A company selling work automation ought to build its own brand assets
that way first.

## What remains

When you evaluate a new multimodal model, do not stop at "does it run". Here the execution
stack alone accounted for 12.7x, and that gap appears nowhere in the model card.

When you quote power, say when the idle baseline was taken. Resident weights alone draw 52W,
and how you amortise that floor changes energy per song by 2.2x.

And separate what has to be exact from what has to be rich. Code owns the three notes of the
logo; the model owns timbre and arrangement. Deciding where **not** to use a generative model
mattered as much as deciding where to use one.

All music here was produced with open-weights models and imitates no living artist's voice or
style. Commercial distribution would require separate licence and disclosure review, and none of
it has been distributed anywhere. The figures above are measured on a single NVIDIA B200 in bf16.
