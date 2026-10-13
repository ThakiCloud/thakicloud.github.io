---
title: "EG2 Hybrid W4 Runtime: Cutting Multimodal Embedding GPU Memory to 0.58x"
seo_title: "EG2 Hybrid W4 Runtime eg2-l2v1: Keeping EmbeddingGemma 2 4-bit Media Weights 4-bit on the GPU for 0.58x Resident Memory - ThakiCloud"
seo_description: "ThakiCloud's eg2-l2v1 v0.1.0 is a runtime that keeps the 4-bit vision and audio weights of EmbeddingGemma 2 in 4 bits on the GPU. Resident memory is 0.58x of BF16, audio throughput is 0.83 to 0.94x, and it is verified on B200 only."
excerpt: "For engineers who need text, image, audio and video search in one embedding space on a tight GPU memory budget. Keeping a 4-bit checkpoint in 4 bits on the GPU brings resident memory down to 0.58x of BF16. It does not run faster, and it is verified on B200 only."
date: 2026-10-14
last_modified_at: 2026-10-14
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "flask"
tags:
  - eg2-l2v1
  - eg2-hybrid-w4-media
  - embeddinggemma-2
  - quantization
  - int4
  - multimodal
  - embedding
  - gpu-memory
  - b200
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/eg2-l2v1-low-memory-runtime/"
header:
  teaser: /assets/images/eg2-l2v1-low-memory-runtime-fig-01.webp
---

If you need to search text, images, audio and video in one embedding space and your GPU memory is tight, this post is for you. A runtime called `eg2-l2v1` keeps the 4-bit media weights in 4 bits on the GPU, and resident memory after loading drops to 0.58x of the BF16 model. It does not make inference faster, and so far it is verified on one GPU type, the NVIDIA B200.

## What you need to know first

The published model [`ThakiCloud/eg2-hybrid-w4-media`](https://huggingface.co/ThakiCloud/eg2-hybrid-w4-media) is a checkpoint of [EmbeddingGemma 2](/tech-blog/en/owm/embeddinggemma-2-multimodal-embedding/) in which the text weights stay in BF16 and only the vision and audio weights are quantized to 4 bits. On disk it is 57% of the upstream BF16 repository.

The model card is candid about one catch. The official loader dequantizes the 4-bit weights back to BF16 when it loads them, so memory after loading is the same as the original BF16 model. The checkpoint alone shrinks the download, not the memory you use at run time.

The GitHub runtime [`ThakiCloud/eg2-l2v1`](https://github.com/ThakiCloud/eg2-l2v1) (v0.1.0) fills that gap. It contains code only and does not redistribute weights. At run time it downloads the public checkpoint at a pinned revision and uses it as is.

## In plain terms

Think of packing winter clothes for a trip. The official loader takes the clothes out of their vacuum bags the moment you reach the hotel and hangs all of them in the closet. The closet, which is GPU memory, fills up with the full-size clothes.

`eg2-l2v1` leaves the clothes in their vacuum bags. When you need an item, it takes out just that one, unrolls it, and puts it back afterwards. The closet stays much emptier, but the unrolling happens every time, so getting ready takes a little longer. Every result in this post fits that picture.

## What changed

The official loader expands every 4-bit vision and audio Linear layer to BF16 at load time. This runtime keeps the 4-bit codes on the GPU and dequantizes a layer's weights only when that layer is called, then feeds them into a BF16 matrix multiply.

The key point is that **this is not a native INT4 GEMM**. The multiply is the same BF16 GEMM, and only the way weights are stored has changed. You give up a little throughput to gain memory.

## Results

All measurements were taken on a single NVIDIA B200. After loading, resident GPU memory is about 0.9 GB, against about 1.5 GB for the BF16 model, which is 0.58x. Accuracy is almost identical to the official loader: embeddings are effectively the same on synthetic inputs (the minimum cosine similarity is in the caption below), and results were bit-identical on real audio.

![Official BF16 loader resident 1.502 GB, eg2-l2v1 resident 0.874 GB, but eg2-l2v1 peaks at 1.797 GB while loading](/assets/images/eg2-l2v1-low-memory-runtime-fig-01.webp)
*Figure 1. GPU memory on B200. The minimum cosine similarity against the official loader on synthetic inputs is at least 0.9999998. Resident memory drops, but the peak during loading is higher than the BF16 resident size.*

One warning. During loading, memory peaks at about 1.8 GB. If you size your budget from the resident figure alone, loading can fail, so leave headroom for that peak when you deploy.

In other words, it takes less room once unpacked, but it needs a wider floor for a moment while unpacking.

### Throughput goes down

Throughput is the median of three rounds, alternating with BF16 in the same process. The table shows throughput relative to BF16 on 3-second synthetic inputs.

| Modality | batch 16 | batch 64 |
|---|---|---|
| text | 1.014 | 1.002 |
| image | 0.956 | 0.988 |
| audio | 0.825 | 0.875 |
| video | 0.989 | 0.998 |

Text and video barely change, and audio slows down the most. On real recordings (FSD50K dev, 64 clips per length bucket), audio throughput is 0.83 to 0.94x of BF16.

![Throughput relative to BF16 by real audio clip length: lowest at 0.831 for clips up to 4 seconds at batch 16, rising to 0.984 near 30 seconds at batch 64](/assets/images/eg2-l2v1-low-memory-runtime-fig-02.webp)
*Figure 2. Throughput by real audio clip length (BF16 = 1.0). Short clips and small batches are the worst case.*

Short audio is hit hardest, and the gap narrows as clips get longer and batches get larger. Activation memory during the forward pass is the same as BF16: 64 clips of 30 seconds need an extra 6.2 GB. Only the weight memory shrinks.

## What about retrieval quality?

The embeddings from this runtime are almost the same as the official loader's, so we expect the retrieval conclusions in the model card to hold. We have not rerun that retrieval evaluation with this runtime, though. The card states that image, audio and video retrieval met non-inferiority criteria against BF16 that were fixed in advance. The evaluation data and harness are internal, though, so outsiders cannot reproduce them directly. If your application depends on exact neighbor order, such as deduplication or near-duplicate checks, validate on your own data.

## Try it

```bash
git clone https://github.com/ThakiCloud/eg2-l2v1.git && cd eg2-l2v1
bash install.sh
python selftest.py --out result.json     # exit 0 means pass
```

The install script pins versions with a lock file, and the selftest checks embedding agreement with the official loader and measures memory. Feed audio as 16 kHz mono float32; clips longer than 30 seconds are truncated to 30 seconds by the model's processor.

## When to use it

It fits when GPU memory is the bottleneck and you can accept a small throughput loss. A typical case is an inference serving setup where the embedding model must share one GPU with other models. If embeddings sit at the bottom of a work-automation flow where agents search documents, screens and voice in one space, saving weight memory leaves room to put more on the same GPU. If memory is not your constraint, the official loader is faster for image and audio, so use that.

## What not to trust

- The only verified GPU is the B200 (SM 10.0). On H200 the median met the same criteria, but one of three rounds measured audio at batch 16 at 0.796, so H200 is not on the supported list.
- It works only with the 4-bit checkpoint. There is no CPU path, so use the official loader on CPU.
- It is not a tool for speed.
- We have not started an inference endpoint on this checkpoint to validate it. Every number in this post comes from the loader and embedding stage.

These are measured values from a single B200, not simulations, and both the code and the model are public under Apache-2.0.
