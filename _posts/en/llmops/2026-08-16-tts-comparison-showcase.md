---
title: "Five TTS Models, Four Languages: Which One Should You Actually Use"
excerpt: "Qwen3-TTS, VoxCPM2, Zonos, Supertonic-3, and Kokoro-82M read the same sentences in four languages. 61 audio samples, grouped by language, so you can listen and decide for yourself which model fits your use case."
seo_title: "Multilingual TTS Comparison: Korean, English, Chinese, Japanese Samples"
seo_description: "Listen to Qwen3-TTS, VoxCPM2, Zonos, Supertonic-3, and Kokoro-82M synthesize Korean, English, Chinese, and Japanese speech, and decide which model to pick per language. 61 samples plus measured naturalness, speed, and emotion metrics."
date: 2026-08-16
last_modified_at: 2026-08-16
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "headphones"
header:
  teaser: /assets/images/tts-comparison-showcase-hero.png
tags:
  - text-to-speech
  - multilingual-tts
  - korean-tts
  - model-selection
  - audio-samples
  - inference-serving
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/tts-comparison-showcase/"
---

![Multilingual TTS comparison]({{ site.url }}{{ site.baseurl }}/assets/images/tts-comparison-showcase-hero.png)
*Six models read the same sentences in four languages.*

The most reliable way to pick a text-to-speech model is to listen to it. So we had six models
read the same sentences in Korean, English, Chinese, and Japanese, and lined up **68 samples,
grouped by language**. You only need to open the section for the language you actually ship.

Here's the short version first.

| Language | If you need real-time | If you need quality | Avoid |
|---|---|---|---|
| Korean | VoxCPM2 (RTF 0.100) | Supertonic-3 | Kokoro (unsupported) |
| English | Kokoro-82M (CPU is enough) | Any of them (small gap) | None |
| Chinese | VoxCPM2 | Qwen3-TTS | **Zonos (broken)** |
| Japanese | VoxCPM2 | Supertonic-3 | All models need review |

## Korean

Four models support Korean. Kokoro-82M is missing because it doesn't support the language at all.

> 오늘 회의는 오후에 삼층 회의실에서 시작합니다. (Today's meeting starts on the third floor this afternoon.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ko-chatterbox-ml.mp3"></audio></p>

> 어제 회의에서 결정된 내용을 반영해 초안을 수정했지만, 검토가 아직 끝나지 않아서 오늘 배포는 어려울 것 같습니다. (I revised the draft to reflect yesterday's decisions, but since review isn't finished, shipping today looks unlikely.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ko-chatterbox-ml.mp3"></audio></p>

**Supertonic-3 is the clearest of the four.** On the intelligibility sub-axis it scores 63.84, the
highest of the set, and it holds a similar lead in the other languages too. The cost is an RTF of
2.498, two and a half times slower than real time, which puts it squarely in the pre-rendered
announcement bucket rather than anything live.

If you need real time, VoxCPM2 wins outright at an RTF of 0.100. But its intelligibility sits at
48.63, the lowest of the group. Qwen3-TTS lands at 61.46 in the same language, a 13-point gap. The
voice itself sounds the most human of any model here (it tops the speaker sub-axis at 71.79), but
that combination comes with phonemes that blur together, so if you're planning to read numbers or
codes out loud, you need preprocessing in front of it, no exceptions.

Zonos sits in between at an RTF of 0.592, still inside real-time bounds. It does accept emotion
instructions, but as you'll see further down, the output doesn't actually move toward the emotion
you asked for, so it's not one to reach for if emotional control is the point.


## English

All five models support English.

> The meeting will start this afternoon in the third floor conference room.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-en-kokoro-82m.mp3"></audio></p>

> I revised the draft to reflect what we decided yesterday, but since the review is not finished, shipping today seems unlikely.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-en-kokoro-82m.mp3"></audio></p>

**Quality doesn't do much to separate these five in English.** Overall naturalness clusters tightly
between 70.09 and 76.45, and every model's median transcription error is zero. With quality this
close, the deciding factors are speed and cost.

On that front, **Kokoro-82M** stands out. On 32 CPU cores it runs at an RTF of 0.640, faster than
real time, while still hitting a naturalness score of 73.87, within three points of the GPU-backed
models. If English and Chinese are all you need, you can run the whole pipeline without touching a
GPU.


## Chinese

Four models claim to support Chinese, but only three are actually usable.

> 会议将在今天下午于三楼会议室举行。 (The meeting will be held this afternoon on the third floor.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-zonos2.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-zh-kokoro-82m.mp3"></audio></p>

> 我已经按照昨天的决定修改了草稿，但因为评审还没结束，今天上线恐怕来不及。 (I revised the draft per yesterday's decision, but since review isn't finished, today's launch probably won't make it.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-zonos2.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-chatterbox-ml.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-zh-kokoro-82m.mp3"></audio></p>

**Qwen3-TTS is the safe pick.** It scores 56.89 on intelligibility versus VoxCPM2's 50.00, and its
90th-percentile transcription error comes in at 0.289 against VoxCPM2's 0.435, a noticeably
shorter tail. Chinese is where the spread between the median and the worst cases opens up the
most, so judging by the median alone will steer you wrong.

⛔ **Do not use Zonos for Chinese.** As you heard in the samples above, what comes out isn't a
sentence, it's the same syllable repeated. The model's language list on its own repo includes
Chinese, but our measured error rate ranged from 1.0 to 6.9. A support list is a claim, not a
measurement.


## Japanese

All four models here support Japanese.

> 会議は今日の午後、三階の会議室で始まります。 (The meeting starts this afternoon on the third floor.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a1-ja-chatterbox-ml.mp3"></audio></p>

> 昨日の会議で決まった内容を反映して草案を修正しましたが、レビューがまだ終わっていないため、今日のリリースは難しそうです。 (I revised the draft to reflect yesterday's meeting outcome, but since review isn't finished, today's release looks difficult.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-voxcpm2.mp3"></audio></p>
<p><strong>Zonos</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-zonos2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-supertonic-3.mp3"></audio></p>
<p><strong>Chatterbox-ML</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a2-ja-chatterbox-ml.mp3"></audio></p>

**Supertonic-3 leads here too.** Overall naturalness comes in at 68.08, the highest of the four,
and its intelligibility of 62.99 is also the best-balanced of the set. Median transcription error
sits at 0.008, essentially perfect.

Still, **whichever model you pick, budget time for human review.** At the 90th percentile, Qwen3-TTS
climbs to 0.413 and VoxCPM2 to 0.438. Of the four languages, Japanese consistently had the longest
tail.


## What happens when you feed it numbers and code

The median transcription error is close to zero for nearly every language. But the 90th
percentile jumps hard. That's not error spread evenly across the board; it means **errors cluster
in specific categories**. Split by category and plain statements, questions, and compound
sentences come out nearly flawless, while numbers and technical jargon are where things fall
apart.

Here are two utterances that actually failed. Compare the source text to what you hear, and you'll
be able to pinpoint exactly where it breaks.

> (technical) API 응답 코드가 503에서 200으로 정상화되었습니다. (The API response code recovered from 503 to 200.)

<p><strong>Zonos · error 14.0968</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ko-zonos2.mp3"></audio></p>

> (technical) モデル名は Qwen3-TTS-12Hz-1.7B で、ライセンスは Apache 2.0 です。 (The model name is Qwen3-TTS-12Hz-1.7B, licensed under Apache 2.0.)

<p><strong>Zonos · error 0.973</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-zonos2.mp3"></audio></p>

For reading a news article aloud, this is harmless. For a service that has to read out amounts,
dates, or product codes, these two categories are exactly where it will bite you. All five models
showed the same pattern, so this isn't one model's defect, it looks like a shared trait of this
generation of TTS. Spelling numbers out into text before synthesis is a thin, cheap preprocessing
step, and it's a lot more reliable than switching models.

## How much does emotion instruction actually change

We synthesized the same sentence in six emotions. The first is a model with strong emotional
range, the second has no emotion control at all.

#### Qwen3-TTS

> 그 사람이 방금 문을 열고 들어왔어요.

The only model where range and accuracy are both significant. The tone shifts, and it shifts toward what was asked for.

<p><strong>Neutral</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-neutral.mp3"></audio></p>
<p><strong>Happy</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-happy.mp3"></audio></p>
<p><strong>Sad</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-sad.mp3"></audio></p>
<p><strong>Angry</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-angry.mp3"></audio></p>
<p><strong>Fear</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-fear.mp3"></audio></p>
<p><strong>Surprise</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-surprise.mp3"></audio></p>

#### Zonos

> 그 사람이 방금 문을 열고 들어왔어요.

The largest shift of any model. Yet a classifier does not recover the requested emotion from it.

<p><strong>Neutral</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-neutral.mp3"></audio></p>
<p><strong>Happy</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-happy.mp3"></audio></p>
<p><strong>Sad</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-sad.mp3"></audio></p>
<p><strong>Angry</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-angry.mp3"></audio></p>
<p><strong>Fear</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-fear.mp3"></audio></p>
<p><strong>Surprise</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-zonos2-surprise.mp3"></audio></p>

#### Chatterbox-ML

> 그 사람이 방금 문을 열고 들어왔어요.

The same signature as Zonos. The audio clearly moves; the accuracy sits at chance.

<p><strong>Neutral</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-neutral.mp3"></audio></p>
<p><strong>Happy</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-happy.mp3"></audio></p>
<p><strong>Sad</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-sad.mp3"></audio></p>
<p><strong>Angry</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-angry.mp3"></audio></p>
<p><strong>Fear</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-fear.mp3"></audio></p>
<p><strong>Surprise</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-chatterbox-ml-surprise.mp3"></audio></p>

#### Kokoro-82M

> He just walked through the door a moment ago.

Six identical renditions. It has no emotion control at all, which is what makes it the noise floor.

<p><strong>Neutral</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-neutral.mp3"></audio></p>
<p><strong>Happy</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-happy.mp3"></audio></p>
<p><strong>Sad</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-sad.mp3"></audio></p>
<p><strong>Angry</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-angry.mp3"></audio></p>
<p><strong>Fear</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-fear.mp3"></audio></p>
<p><strong>Surprise</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-surprise.mp3"></audio></p>

### Emotional expressiveness by model

Turning what you just heard into numbers, we measured two separate things. **Expressive range** is
how much pitch, intensity, and pause prosody actually shift when you change the emotion.
**Hit rate** is how often a speech-emotion classifier, fed that resulting audio, labels it with the
emotion you actually asked for.

| Model | Expressive range | vs. floor | Hit rate | vs. chance | Emotion conditioning |
|---|---|---|---|---|---|
| **Qwen3-TTS** | 0.408 | 16.9x | **0.403** | **2.42x** | Instruct-style text prompt |
| Zonos | **0.452** | 18.8x | 0.167 | 1.00x | Direct 8-dim real-valued vector |
| Chatterbox-ML | 0.445 | 18.4x | 0.181 | 1.08x | Exaggeration scalar |
| Supertonic-3 | 0.255 | 10.6x | 0.222 | 1.33x | Inline style tags |
| Kokoro-82M | 0.024 | 1.0x | 0.167 | 1.00x | **None** |
| VoxCPM2 | not measurable | | | | Reference-audio pairing only |

**What to notice is that the top three rows are effectively tied on expressive range.** Zonos at
0.452, Chatterbox-ML at 0.445, Qwen3-TTS at 0.408, all roughly seventeen times the floor. Move to
hit rate and the first two collapse to chance while only Qwen3-TTS survives.

The confusion matrix makes this concrete. When we asked Zonos for anger, it was classified as
happy 3 times, disgusted 5 times, sad 2 times, and angry zero times. Ask for happy and you get
neutral 6 times, sad 3 times. The audio genuinely changes, it just **doesn't change toward what
was asked for**.

Chatterbox-ML landing in the same place matters more than either result alone. Two models with
different conditioning interfaces, different training, and different authors arrived independently
at the same signature. That points at something general: **moving prosody and aiming that movement
are separate capabilities.** Several models have the first. Most do not have the second.

Qwen3-TTS is the one model where both metrics agree and both are significant. 16.9x expressive
range, 2.42x hit rate: the sound changes, and it changes in the direction you asked for.
**If you need emotional control, this is the model.**

Picking on expressive range alone would have gotten two of six models wrong, so the emotion axis
has to be read on both metrics together, never one alone.

It splits by language too. Qwen3-TTS stays consistent, 0.386 to 0.443 across the four languages,
but Supertonic-3 dips unusually low in English at 0.157 and more than doubles that in Japanese at
0.354. Same model, different language, different amount of traction on the emotion instruction, so
if you're running a multilingual service, verify separately in whichever language you ship.

VoxCPM2 is missing from the table above, and not because it performs badly. This model only
accepts emotion **paired with a reference audio clip**. Ask for an emotion without a reference and
the synthesis simply fails outright. Had we quietly substituted a neutral voice in that case, it
would have gotten logged as "a model with no emotional variation," when in truth the condition
never even applied, so we left it out honestly instead.

The six clips under Kokoro-82M above probably sounded like the same recording to you, and that's
because the model has no emotion control, so all six requests fed it identical input. That makes
it the **floor** for this metric. Its emotion classifier's hit rate is exactly 0.167, which is
precisely the chance probability of landing on the right one of six emotions if you picked
randomly.

Once you know where the floor sits, the rest of the table reads differently. By expressive range
alone, Zonos leads at 0.452, but as you heard, that motion doesn't land on the requested emotion.
**Qwen3-TTS is the only model where both metrics come out significant together.**

Even so, keep the absolute numbers in perspective. Even the best-performing model doesn't get the
requested emotion through to the classifier more than half the time. Think of emotion
instructions less as a switch that flips a feeling on, and more as a dial that nudges the output
slightly in that direction.

## The numbers, all in one place

![Measurement results]({{ site.url }}{{ site.baseurl }}/assets/images/tts-comparison-showcase-results.png)
*Left: naturalness by language. Right: the relationship between speed and intelligibility.*

The chart on the right is the summary of this whole post. Further left is faster, further up is
clearer, and **nothing sits in the upper left.** VoxCPM2, the fastest, sits at the bottom.
Supertonic-3, the clearest, sits at the far right. Speed and intelligibility didn't arrive
together in any of these five models.

We measured naturalness with TTSDS2, which compares the distribution of a set of synthesized
utterances against a set of real human recordings, rather than scoring each utterance one at a
time, so it's less language-sensitive than per-utterance scoring methods. For the human reference,
we used 120 utterances per language from Google FLEURS' validation set.

## How comparisons like this are usually done

If you want to reproduce these results or benchmark a different model yourself, here's a rundown
of the measurement conventions this field generally uses.

**Speed is measured as RTF (real-time factor):** generation time divided by the length of the
synthesized audio. Below 1 means faster than real time, and streaming services usually track
time-to-first-byte (TTFB) alongside it. Our measurement here is sentence-level batch generation.

**Intelligibility is measured through transcription:** run the synthesized audio back through a
speech recognition model and compare against the source text. For languages with clear word
boundaries like English, word error rate (WER) is standard; for languages like Korean, Chinese,
and Japanese without that boundary, character error rate (CER) is used instead. Whisper large-v3
has become the de facto scoring model in this field, and we followed that convention. ⛔ Don't stop
at the median, though. Here too, the median is mostly zero, and the real spread shows up in the
90th percentile.

**Naturalness splits into two approaches.** One scores each utterance individually with an
MOS-prediction model (the UTMOS family); the other compares the **entire distribution** of the
synthesized set against a set of real human speech (TTSDS2). The former is trained mostly on
English and produces uncalibrated scores in other languages. Multilingual comparisons need the
latter, so we made TTSDS2 our primary metric, and we looked not just at the overall score but at
the speaker, prosody, and intelligibility sub-axes together. Looking only at the overall score
would have missed the point of this whole post.

**Emotion still lacks a solid standard.** There's no single widely accepted metric, so we combined
two. Prosody variance measures expressive range, and a speech-emotion recognition model measures
hit rate. **You have to establish a floor first.** Measure a model with no emotion control
alongside the rest and you get the value of "what it looks like when the condition never applied,"
and every other number only means something read as a multiple of that floor. In our case, that
floor came out to 0.024 and 0.167.

**There's one rule that ties it all together: use the same sentences, the same seed, and the same
hardware across every model.** Different sentence sets make results incomparable even under the
same seed number, and that's exactly why we excluded some measurements from the comparison this
time.

## What to use, per language, per use case

Adding the intended use case into the mix gives you this:

| Use case | Korean | English | Chinese | Japanese |
|---|---|---|---|---|
| Real-time conversation | VoxCPM2 + number preprocessing | Kokoro-82M (CPU) | VoxCPM2 | VoxCPM2 |
| Emotionally expressive dialogue | **Qwen3-TTS** | Qwen3-TTS | Qwen3-TTS | Qwen3-TTS |
| Prompts & notifications | Supertonic-3 | Kokoro-82M | Qwen3-TTS | Supertonic-3 |
| Audiobooks & narration | Supertonic-3 | Any of them | Qwen3-TTS | Supertonic-3 |
| All four languages, one model | Chatterbox-ML | Chatterbox-ML | Chatterbox-ML | Chatterbox-ML |
| Amounts & code readout | Preprocessing required | Preprocessing required | Preprocessing required | Preprocessing + review |

The answer changes even within the same language once the use case changes. Real-time
conversation prioritizes latency over quality, so it goes to whichever model has the lowest RTF;
pre-rendered announcement audio has the opposite constraint, more time to spend, so it goes to the
one with the highest intelligibility. Whenever emotion is actually needed, Qwen3-TTS is the only
option. It costs you real-time performance, but it's the only model where the requested emotion
actually comes through.

Chatterbox-ML is alone on that second-to-last row because it is the only model that covers all
four languages while staying under real-time at RTF 0.675. **Do not let the median reassure you,
though.** Its median error rate is a respectable 0.068 in Korean and 0.065 in Chinese, but the
worst decile in Chinese blows out to 0.844. Roughly one sentence in ten comes back hard to follow,
so if it is going into an unattended pipeline, pair it with output validation.

Since the best choice differs per language, a thin routing layer keyed by language lets you pull
English traffic onto CPU while still using the strongest model in each language. If operational
simplicity matters more to you, covering all four with Chatterbox-ML and adding review is the
cheaper thing to maintain.

## Limitations worth knowing about

FLEURS is read-speech. The utterances are recorded as clean, deliberate readings, so this
naturalness score is accurate as a measure of **how well a model produces read-style speech**, not
conversational speech. If your target is a conversational agent, it's worth re-measuring against a
dialogue corpus instead.

Don't trust the power numbers from the two models we ran on CPU. Running the identical
configuration three times back to back, net incremental power swung by 178 percent. That's a
shared-node idle-baseline problem; the speed measurements from those same runs only moved by 7.9
percent, so the speed comparisons still hold.

Finally, only five of twelve candidate models made it into this post. Most of the rest were
voice-cloning models with no default speaker, requiring a reference audio clip to run at all. The
moment you feed a model a reference clip, what you're measuring shifts from speech synthesis
quality to cloning fidelity, so we didn't mix them into the same table. That's a separate
comparison for another post.

---

All 61 samples here are the actual synthesized output from this measurement run, converted
straight from the files the ledger points to, with no post-processing or cherry-picking.
