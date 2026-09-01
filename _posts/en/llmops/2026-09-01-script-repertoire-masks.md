---
title: "We Reused a Korean Han-Character Filter on Japanese and It Cut 11 Ordinary Words"
excerpt: "A mask that suppressed Chinese characters in Korean output inverted when we moved it to Japanese. Simplified-versus-traditional conversion cannot separate Japanese shinjitai, and a Traditional Chinese mask deletes Cantonese's own characters. We switched the test to legacy national encodings and published masks for six languages."
seo_title: "Multilingual LLM Script Leakage: Per-Language Vocabulary Masks"
seo_description: "Applying Qwen3.8-27B's Korean CJK mask to Japanese cuts 11 of 12 common words. OpenCC misreads shinjitai as simplified and Big5 excludes Cantonese characters. We release per-language masks judged by Shift-JIS, Big5-HKSCS and iso8859-6 repertoires."
date: 2026-09-01
published: true
categories:
  - llmops
tags:
  - multilingual
  - language-confusion
  - code-switching
  - vocabulary-pruning
  - qwen
  - tokenizer
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/script-repertoire-masks/"
---

If you serve a multilingual LLM to Korean, Japanese, or Arabic users, this post gives you one thing. **A filter that stops script leakage has to be designed per language, and the right test is not simplified-versus-traditional. It is the legacy national encoding.** Move a filter that works in one language to its neighbour and you will delete that neighbour's ordinary vocabulary.

## Plain terms

Characters carry passports.

Korea, Japan, China, and Taiwan all write Han characters, but each shortened them differently during the twentieth century. Japan reduced `國` to `国`. China reduced it to `国` as well. Taiwan and Korea kept `國`. So asking "is `国` a Chinese character?" has no answer. It holds a Japanese passport and a Chinese one.

The method here is about where you get the passport list. Every country built an encoding standard to hold its own script, and that standard is effectively **the list of characters that country claims as its own**. Japan has Shift-JIS, Taiwan has Big5, Hong Kong has Big5-HKSCS, and the Arabic world has iso8859-6. Use those lists as the passport desk.

## What we tried

Last week we built a mask that reduces Han-character leakage in Korean output. It presses down the output-layer rows for 54,902 tokens that spell Chinese words, and it dropped Korean contamination from 2.6% to 0.7%. Korean Hanja glosses survived.

This time we asked whether that mask transfers. The test is simple. Feed each language's ordinary vocabulary through the tokenizer and count how many of those tokens the mask catches. No GPU, a few seconds.

## What came out

### In Japanese the method inverts

We ran the Korean mask against twelve common Japanese words. **Eleven were cut.**

```
日本語 cut · 会議 cut · 時間 cut · 電話 cut · 勉強 cut · 経済 cut
国際 cut · 実際 cut · 学校 cut · 写真 cut · 広告 cut     (only 気持 survived)
```

The cause sits in the mask's core rule. The Korean mask treats "two or more Han characters in a row" as a Chinese word. That holds because Korean uses Han only as single-character glosses, as in `개항(開港)`. In Japanese, two Han characters in a row is not Chinese. It is **Japanese itself**. The premise flips.

In plain terms: what reads as a suspicious signal in Korean is the most ordinary sentence in Japanese.

### A simplified-traditional converter cannot find shinjitai

There is a quieter trap. If you reach for the usual converter (OpenCC) to decide "is this a simplified character", it misreads Japanese shinjitai.

| Character | Converter verdict | Reality |
|---|---|---|
| 国 学 会 写 独 当 来 | simplified, so cut | Japanese shinjitai *and* Chinese simplified |
| 実 気 広 経 歩 | unchanged, so kept | Japanese shinjitai |

Japan and China each simplified their characters, and **the results overlap heavily**. An axis that asks "was this character shortened?" cannot separate the two countries. Asking whether Shift-JIS contains it does: `国`, `学`, and `会` pass while `这`, `们`, `说`, and `华` are caught. Rebuilding the Japanese mask on that test kept all twelve Japanese words and caught all eight Chinese ones.

### A Traditional Chinese mask deletes Cantonese

Big5 works well for Traditional Chinese. It catches simplified-only forms and Japanese shinjitai in one pass. But applied to Cantonese, it removes Cantonese's own writing.

Of eleven Cantonese-specific characters, **five (`嘅` `喺` `啲` `哋` `嘢`) fall outside Big5**. Switching to the Hong Kong extension, Big5-HKSCS, brings all eleven inside. That standard exists precisely to carry these characters.

There is a cost. HKSCS has a wider repertoire and includes the Japanese shinjitai `実`. So the Cantonese mask blocks shinjitai less well than the Traditional Chinese one. That is the price of keeping Cantonese vocabulary, and no encoding satisfies both.

### Arabic turned out to be a different problem

We tokenized Arabic sentences and counted tokens shared with the Korean mask. The answer was **exactly zero**. The scripts do not overlap, so that follows. Arabic was not something to port. It was something to design.

What actually leaks into Arabic output is **Persian and Urdu orthography**, which shares the same Unicode block. Two pairs are especially hard to see.

| Standard Arabic | Perso-Urdu | Appearance |
|---|---|---|
| ي (YEH) | ی (FARSI YEH) | nearly identical |
| ك (KAF) | ک (KEHEH) | nearly identical |

A reader may not notice, but search, normalization, and speech synthesis all break. Add the consonants `پ چ ژ گ`, which Arabic does not have, plus Urdu-only letters. The iso8859-6 test catches these. Arabic-Indic digits and vowel marks fall outside that standard, so we kept them explicitly.

### The probe caught one of my mistakes

While building the Arabic mask I had classified the honorific ligature `ﷺ` as a contaminant. It is ordinary Arabic text and I was simply wrong. Putting it in the preservation check surfaced it immediately, and that also revealed that the more aggressive tier cuts both `ﷺ` and `ﷲ`. We dropped that tier from the default.

## What to change

Two things.

First, **move the test to legacy national encodings.** The simplified-traditional axis is valid inside Chinese and wrong the moment it crosses a border. The encoding test needs only the Python standard library and no external dependency.

Second, **let the tier structure differ per language.** Masks come in tiers because there is legitimate overlap to protect, and the size of that overlap varies. Korean needs three tiers to preserve Hanja glosses. Vietnamese needs one, because modern Vietnamese orthography contains no Han characters at all, so a full mask is already optimal. Forcing a uniform tier count guarantees that one language is handled wrongly.

We published masks and an apply script for six languages. We did not upload weights. Only one tensor changes, so downloading the original and running the script beats copying 55.6GB, and it follows base-model updates.

| Language | Test | Default mask size |
|---|---|---|
| Korean | simplified + kana, plus 2+ pure-Han runs | 54,902 |
| Japanese | Shift-JIS repertoire | 24,795 |
| Traditional Chinese | Big5 repertoire | 32,211 |
| Cantonese | Big5-HKSCS repertoire | 24,743 |
| Vietnamese | all Han, kana, Hangul | 65,695 |
| Arabic | iso8859-6 plus digit and vowel-mark exceptions | 815 |

## What you should not trust

This part matters.

**Only Korean has been measured.** For the other five languages we verified what the mask cuts and what it keeps, and nothing more. We did not measure how far contamination actually falls, and we did not measure capability regression. Every repository card says so at the top.

There is a reason for the caution. We applied the same recipe to a smaller model, Qwen3.5-0.8B, and the predicted 0.2% came out as 1.3% in practice. We still do not know why. Being right in the tokenizer does not guarantee being right during generation.

The Japanese mask has a known hole. `个` is very common in Chinese but sits inside Shift-JIS, so it survives. That is a false positive of the encoding test.

The technique also has a boundary. **English leakage cannot be fixed this way.** English tokens must stay for code, proper nouns, and units, so they are not a removable contaminant. For languages whose main intrusion is English, such as Thai or Indonesian, this method does not reach.

## Repositories

[Korean](https://huggingface.co/ThakiCloud/Qwen3.8-27B-ko-cjk-suppressed) · [Japanese](https://huggingface.co/ThakiCloud/Qwen3.8-27B-ja-cjk-suppressed) · [Traditional Chinese](https://huggingface.co/ThakiCloud/Qwen3.8-27B-zhTW-cjk-suppressed) · [Cantonese](https://huggingface.co/ThakiCloud/Qwen3.8-27B-yue-cjk-suppressed) · [Vietnamese](https://huggingface.co/ThakiCloud/Qwen3.8-27B-vi-cjk-suppressed) · [Arabic](https://huggingface.co/ThakiCloud/Qwen3.8-27B-ar-script-suppressed)

Prior work in the same direction: [smoothie-qwen](https://github.com/dnotitia/smoothie-qwen) ships pre-adjusted checkpoints that suppress Chinese via output-layer edits. What this post adds is the per-target-language repertoire test and the per-language tier structure.
