---
title: "Four TTS Models, Head to Head: Pick Your Language by Ear"
excerpt: "One Korean sentence, read by four models. Same text, same conditions, same harness. Listen first, then look at the table: it clicks immediately why VoxCPM2 runs 12x faster than Qwen3-TTS yet still misses the emotion axis, and why you should never let any of them read a dollar amount out loud."
seo_title: "Multilingual TTS Comparison: Audio Samples and a Language by Language Picking Guide"
seo_description: "We synthesized 36 samples in Korean, English, Chinese, and Japanese across Qwen3-TTS, VoxCPM2, Supertonic-3, and Kokoro-82M, and you can listen to every one. RTF, power draw, accuracy, and emotional expressiveness, measured, plus a per-language recommendation."
date: 2026-08-16
last_modified_at: 2026-08-16
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "headphones"
tags:
  - text-to-speech
  - multilingual-tts
  - audio-samples
  - model-selection
  - inference-serving
  - korean-tts
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/tts-comparison-showcase/"
---

One Korean sentence, read by four models. Same text, same conditions, same harness. Listen first,
and the rest of this post will make a lot more sense.

> 오늘 회의는 오후에 삼층 회의실에서 시작합니다. (Today's meeting starts this afternoon in the third floor conference room.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-supertonic-3.mp3"></audio></p>

If you could hear the difference between those three, here is what it looks like in numbers.

### Performance at a glance

| Model | Hardware | Languages | RTF (p95) | Streams per GPU | gross J per audio-sec | GPU idle | EFI | SER |
|---|---|---|---|---|---|---|---|---|
| VoxCPM2 | B200 | 4 | **0.1** (0.124) | 10.0 | 97.2 | 43.4% | n/a | n/a |
| Kokoro-82M | CPU 32c | 2 | **0.64** (1.344) | 1.6 | 301.1 | n/a | 0.0241 | 0.1667 |
| Qwen3-TTS-1.7B | B200 | 4 | **1.196** (1.306) | 0.8 | 815.8 | 86.7% | 0.4075 | 0.4028 |
| Supertonic-3 | CPU 32c | 3 | **2.497** (3.534) | 0.4 | 1581.2 | n/a | 0.2549 | 0.2222 |

### Accuracy by language (CER/WER median · p90)

| Model | ko | en | zh | ja |
|---|---|---|---|---|
| VoxCPM2 | 0.000 / 0.217 | 0.000 / 0.167 | 0.026 / 0.435 | 0.103 / 0.438 |
| Kokoro-82M | n/a | 0.000 / 0.107 | 0.040 / 0.438 | n/a |
| Qwen3-TTS-1.7B | 0.000 / 0.295 | 0.000 / 0.092 | 0.000 / 0.289 | 0.044 / 0.413 |
| Supertonic-3 | 0.000 / 0.292 | 0.000 / 0.175 | n/a | 0.008 / 0.321 |

### UTMOS by language (warning: only en is calibrated)

| Model | ko | en | zh | ja |
|---|---|---|---|---|
| VoxCPM2 | 2.9312 ⚠️ | 4.1584 | 3.2682 ⚠️ | 2.9821 ⚠️ |
| Kokoro-82M | n/a | 4.515 | 3.9564 ⚠️ | n/a |
| Qwen3-TTS-1.7B | 3.7056 ⚠️ | 4.3666 | 3.3001 ⚠️ | 3.3059 ⚠️ |
| Supertonic-3 | 3.9297 ⚠️ | 4.4752 | n/a | 4.1711 ⚠️ |

Lower RTF is faster. An RTF of 1.0 means it takes one second to generate one second of audio, so
you need to stay below that for anything real time. **VoxCPM2 comes in at 0.100, handling ten
concurrent streams on a single B200, while Qwen3-TTS sits at 1.196 and cannot even keep up with
one stream.** That is a 12x gap.

Power is reported as an absolute number. 86.7% of what Qwen3-TTS draws is idle overhead unrelated
to synthesis itself, so an endpoint that cannot fill its batch burns an entire GPU to produce a
single stream.

## How to pick by language

### Korean

**Go with VoxCPM2 for real time, Supertonic-3 for quality.** VoxCPM2 dominates on RTF at 0.100
but its UTMOS of 2.93 is the lowest of the four models. Supertonic-3 tops out at 3.93 but costs
you an RTF of 2.498, two and a half times real time. If you are pre-generating something like an
announcement voice, Supertonic is the right call; for anything conversational, trade quality for
VoxCPM2's speed.

Kokoro-82M does not support Korean at all, which is exactly why we logged what each model card
claims to support separately from what we actually measured.

### English

**You can pick on speed and power alone.** UTMOS ranges narrowly from 4.16 to 4.52 across all four
models, so quality differences barely matter. CER medians are all 0 as well. That leaves RTF and
power as the deciding factors, and on that axis VoxCPM2 wins on GPU while Kokoro-82M wins on CPU.

Kokoro-82M in particular is a **no GPU needed option** if you only need English and Chinese. At
RTF 0.640 on 32 CPU cores, it beats real time without ever touching a GPU.

### Chinese

**Qwen3-TTS is the safe choice.** Its CER median is 0 and its p90 is 0.289, a much shorter tail
than VoxCPM2's 0.435 or Kokoro's 0.438. Chinese accuracy diverges sharply in the worst 10% of
utterances, so judging by the median alone will mislead you.

### Japanese

**Whichever model you use, check the p90.** Qwen3-TTS at 0.413, VoxCPM2 at 0.438, and Supertonic-3
at 0.321 all show a long tail in Japanese. Supertonic-3 is the least bad of the three. If you are
building a Japanese announcement voice, budget for reviewing every single output.

## What happens when you make it read numbers and jargon

The accuracy table's medians all sit near zero, yet the p90 spikes. That means errors are not
spread evenly, they cluster in specific categories. Broken down by category, plain statements,
questions, and compound sentences come through nearly perfect, and everything falls apart on
**numbers and technical jargon.**

Here are utterances that actually failed. Compare the source text to what you hear and you can
tell exactly where it breaks.

> (Korean, technical) 자세한 내용은 docs.thakicloud.net 문서를 참고해 주세요. (For details, please refer to the documentation at docs.thakicloud.net.)

<p><strong>Qwen3-TTS n/a error 0.5641</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ko-qwen3-tts-1.7b.mp3"></audio></p>

> (Japanese, technical) 詳しくは docs.thakicloud.net のドキュメントをご参照ください。 (For details, please refer to the documentation at docs.thakicloud.net.)

<p><strong>Qwen3-TTS n/a error 0.5556</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-qwen3-tts-1.7b.mp3"></audio></p>

> (Chinese, numeric) 内存占用从六十四GB一夜之间涨到了一百二十八GB。 (Memory usage jumped from 64GB to 128GB overnight.)

<p><strong>VoxCPM2 n/a error 0.5417</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-zh-voxcpm2.mp3"></audio></p>

> (Japanese, numeric) メモリ使用量が六十四ギガバイトから百二十八ギガバイトに増えました。 (Memory usage increased from 64GB to 128GB.)

<p><strong>VoxCPM2 n/a error 0.5312</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-voxcpm2.mp3"></audio></p>

> (Japanese, numeric) メモリ使用量が六十四ギガバイトから百二十八ギガバイトに増えました。 (Memory usage increased from 64GB to 128GB.)

<p><strong>Supertonic-3 n/a error 0.5312</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-ja-supertonic-3.mp3"></audio></p>

> (Chinese, numeric) 部署时间定在二零二六年八月十四日上午九点三十分。 (Deployment is scheduled for 9:30 AM on August 14, 2026.)

<p><strong>Qwen3-TTS n/a error 0.4348</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/b-zh-qwen3-tts-1.7b.mp3"></audio></p>

None of this matters if the model is just reading an article aloud. But if your service needs to
read dollar amounts, dates, or product codes, these two categories are exactly where it breaks.
Preprocessing numbers into spelled out text ahead of time is a far more reliable fix than swapping
models.

## What "the emotion tag actually works" means

We synthesized the same sentence in six emotions. The model at the top showed the strongest
emotional range; the one at the bottom has no emotion control at all. Hearing the difference is
faster than reading about it.

#### Qwen3-TTS

> 그 사람이 방금 문을 열고 들어왔어요. (That person just opened the door and walked in.)

<p><strong>Neutral</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-neutral.mp3"></audio></p>
<p><strong>Happy</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-happy.mp3"></audio></p>
<p><strong>Sad</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-sad.mp3"></audio></p>
<p><strong>Angry</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-angry.mp3"></audio></p>
<p><strong>Fearful</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-fear.mp3"></audio></p>
<p><strong>Surprised</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-ko-qwen3-tts-1.7b-surprise.mp3"></audio></p>

#### Kokoro-82M

> He just walked through the door a moment ago.

<p><strong>Neutral</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-neutral.mp3"></audio></p>
<p><strong>Happy</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-happy.mp3"></audio></p>
<p><strong>Sad</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-sad.mp3"></audio></p>
<p><strong>Angry</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-angry.mp3"></audio></p>
<p><strong>Fearful</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-fear.mp3"></audio></p>
<p><strong>Surprised</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/c-en-kokoro-82m-surprise.mp3"></audio></p>

The six Kokoro-82M clips are effectively the same recording. The model has no emotion control API,
so all six conditions collapse into the same input. That makes it the **floor of these metrics**:
EFI, which measures prosodic variance, comes out to 0.024, and SER, the rate at which an emotion
classifier correctly identifies the requested emotion, comes out to 0.167, exactly the chance rate
of guessing among six emotions uniformly at random.

Once you know the floor, Qwen3-TTS's EFI of 0.408 reads as 17x the floor, and its SER of 0.403
reads as 2.4x chance. Still, keep the absolute numbers in perspective: even the best performer
here gets the requested emotion through to the classifier less than half the time. **An emotion
tag is not a switch that turns that emotion on, it is a dial that nudges the delivery slightly in
that direction.**

## The remaining language samples

#### Korean

> 오늘 회의는 오후에 삼층 회의실에서 시작합니다. (Today's meeting starts this afternoon in the third floor conference room.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ko-supertonic-3.mp3"></audio></p>

#### English

> The meeting will start this afternoon in the third floor conference room.

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-supertonic-3.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-en-kokoro-82m.mp3"></audio></p>

#### Chinese

> 会议将在今天下午于三楼会议室举行。 (The meeting will be held this afternoon on the third floor.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-zh-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-zh-voxcpm2.mp3"></audio></p>
<p><strong>Kokoro-82M</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-zh-kokoro-82m.mp3"></audio></p>

#### Japanese

> 会議は今日の午後、三階の会議室で始まります。 (The meeting starts this afternoon in the third floor conference room.)

<p><strong>Qwen3-TTS</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ja-qwen3-tts-1.7b.mp3"></audio></p>
<p><strong>VoxCPM2</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ja-voxcpm2.mp3"></audio></p>
<p><strong>Supertonic-3</strong><br>
<audio controls preload="none" src="/assets/audio/posts/tts-comparison-showcase/a-ja-supertonic-3.mp3"></audio></p>

## The limits of these numbers

We measured everything with the same harness and kept a ledger of the raw results. Still, there
are three things worth stating plainly.

UTMOS is a predictor trained on English, so its Korean, Chinese, and Japanese values are not
calibrated. You can use it to rank models within the same language, but you should not compare it
across languages. The cells marked with a warning symbol in the table are exactly that case.

We measured power for the two CPU models on a shared node. Running the identical setup three times
in a row, the net power delta swung by 178%. That is why the table only reports absolute values,
and why we did not compare power draw between the two CPU models.

Only four of the twelve models on our roster made it through the full run. The rest either had
unverified Python API contracts or required cloning and installing a repo, so we could not fit
them into this round. We will cover them next time.

---

All 36 samples are real synthesis outputs from this experiment, converted straight to mp3 from the
files the ledger points to, with no post-processing or cherry-picking.
