---
title: "Why the same NVFP4 checkpoint was 9GB heavier"
excerpt: "Excluding attention from quantization leaves it in bf16. It looks like the safe choice, but it is the most expensive item on the menu, and that was the entire gap."
categories:
  - research
tags:
  - quantization
  - nvfp4
  - vllm
  - b200
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/qwen38-nvfp4-fp8attn/"
audiobook: "https://drive.google.com/file/d/1-2PyUiQ-XhFXwgUWr8iwgcAlEJfWCOj0/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you quantize models for serving, you have probably run into this. A public checkpoint and the
one you built carry the same format name, but the sizes differ.

In our case it was **28.07 GiB versus about 19 GiB.** Both are labeled "NVFP4." Tracing the cause,
it was not the number format but **how attention was handled**, and fixing it cut the size **to
21.34 GiB, a 24% reduction.**

![Illustration of the core idea of Why the same NVFP4 checkpoint was 9GB heavier](/assets/images/qwen38-nvfp4-fp8attn-hero.webp)
*A visual metaphor for the article's key idea.*

## Excluding is not the safe choice

Our quantization script was excluding attention with `--extra-ignore`. The reasoning was that
dropping attention to 4 bits is risky for quality, and that judgment itself was correct.

The problem is that **excluding it leaves it in bf16.** Leaving something out of quantization does
not mean "leave it untouched," it means "keep it at 16 bits," and that is the most expensive
option on the menu. The public build was putting **FP8** in the same slot.

This model has 48 of its 64 layers as linear attention, so the weight is large. If attention stays
in bf16, that much of the model is entirely 16-bit.

The code comment at the time read: *"Our quantizer can only exclude, so we exclude it."* That
sentence **was right about the call we were making and wrong about the library.**

## Before fixing it, we checked three things first

A single quantization run takes 47 minutes. If the path is blocked, you find out after burning 47
minutes. So before building, we checked three gates in the source.

First, can llm-compressor express different precision per module. We assumed the `scheme`
argument only took a string, but it also takes a dictionary. Second, how are overlapping targets
resolved. An exact name beats a regex, and a regex beats a class name, so specifying attention by
regex automatically overrides a blanket `Linear` target. Third, does vLLM read mixed-precision
checkpoints. It reads a per-group format field.

All three were open, which made a recipe of MLP in NVFP4 and attention in FP8 viable.

## We checked the tensors, not the config

After the build finished, we opened the saved weights directly.

```
linear_attn.weight    F8_E4M3     <- was all BF16 before
self_attn.weight      F8_E4M3
mlp.weight_packed     U8          <- NVFP4, unchanged
```

A config file saying "mixed precision" and the tensors actually being FP8 are different claims.
Checking the latter is what counts as confirmation.

## We nearly drew the opposite conclusion

The first measurement came back at **49.37 GiB.** Against an original of 51.77 GiB, that reads as
"barely any compression at all."

What had actually happened was that the uploader had not cleared the destination, so **seven
shards from the old build and five shards from the new build were sitting overlapped in the same
directory.** The index file pointed to the new ones, and the real size was 21.34 GiB.

Directory size is not build size. And overwriting the same path also changes the checkpoint
currently being served. We changed the build script so different recipes write to different
paths.

## What we did not measure

We only measured size. The hypothesis that bf16 attention cannot use B200's FP8 tensor cores and
runs slower is plausible, and on the same day the public build's response time came in at 7.8
seconds against 10.7 seconds for ours. But that is end to end latency, and we did not check which
kernel got selected per attention layer. To claim the size reduction explains the speed, that is
what you would need to look at.

We did not measure quality either. This post is about the recipe change and the size reduction,
not accuracy.

The remaining 2 GiB gap against the public build comes from `lm_head` and the vision tower. Their
build quantizes both, ours leaves them as is. `lm_head` has a vocabulary of 150,000 and feeds
directly into logit quality, and matching pass rates alone did not seem like enough reason to
bring it down to 4 bits.

## References

- [vLLM](https://github.com/vllm-project/vllm): the official repository of the serving engine we
  checked for mixed-precision checkpoint support in this post.
- [LLM Compressor](https://github.com/vllm-project/llm-compressor): the official tool we used to
  quantize with different precision per module, supporting formats including NVFP4 and FP8.
- [NVFP4: A 4-Bit Floating Point Format for AI Inference](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/):
  the official blog post describing the 4-bit floating point format introduced with the NVIDIA
  Blackwell architecture.
- [FP8 Primer](https://docs.nvidia.com/deeplearning/transformer-engine/user-guide/examples/fp8_primer.html):
  the official NVIDIA Transformer Engine documentation covering the scaling method for the 8-bit
  floating point format.
- [NVIDIA Blackwell Architecture](https://www.nvidia.com/en-us/data-center/technologies/blackwell-architecture/):
  the official page describing the Blackwell GPU architecture that B200 belongs to and its FP8
  tensor core support.
