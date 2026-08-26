---
title: "The Same Four Bits Land on Opposite Sides of FP8"
excerpt: "We served a single coder MoE model on a B200 at four precisions: NVFP4 came out faster than FP8, and W4A16 came out slower. Here is why equal bit width does not mean equal sign, and why you should suspect the benchmark first when a 4-bit measurement comes out slow."
seo_title: "NVFP4 vs FP8 vs W4A16: A B200 4-bit Serving Measurement - Thaki Cloud"
seo_description: "We measured Qwen3-Coder-30B-A3B at four precisions, bf16, FP8, W4A16, and NVFP4, on a single B200. NVFP4 runs 1.07x to 1.32x faster than FP8, and W4A16 runs at 0.75x to 0.84x. HumanEval shows no distinguishable difference across all four."
date: 2026-08-14
tags:
  - NVFP4
  - FP8
  - Quantization
  - Blackwell
  - LLMOps
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/llmops/nvfp4-vs-fp8-two-four-bits/
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/nvfp4-vs-fp8-two-four-bits/"
categories:
  - llmops
audiobook: "https://drive.google.com/file/d/1blW17BCBXj38ZZkgaesVejTOR7czMpgG/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you are picking a precision for MoE serving on Blackwell, treating every 4-bit format as one bucket is the most expensive mistake you can make. Drop the same model to W4A16 and it gets slower than FP8. Drop it to NVFP4 and it gets faster than FP8. Same bit width, opposite sign on the conclusion.

![Image representing the concept of the same four bits landing on opposite sides of FP8](/assets/images/nvfp4-vs-fp8-two-four-bits-hero.webp)
*Visualizing the core idea of this piece.*

## One Model, Four Precisions

We built a single Qwen3-Coder-30B-A3B checkpoint in bf16, FP8, W4A16, and NVFP4, and ran all four through the same workload on one B200. Input was 1,746 tokens, output was 256 tokens, concurrency ran from 1 to 512, and each level was measured three times.

| Concurrency | bf16 | FP8 | W4A16 | NVFP4 |
|---|---|---|---|---|
| 1 | 300.6 | 257.6 | 215.9 | **303.3** |
| 8 | 1,707.1 | 1,491.5 | 1,311.2 | **1,962.2** |
| 32 | 4,454.2 | 3,978.8 | 3,013.3 | **5,099.2** |
| 64 | 6,448.2 | 6,054.7 | 4,292.4 | **7,608.3** |
| 128 | 8,586.2 | 8,130.3 | 5,427.7 | **9,941.8** |
| 256 | 5,982.5 | 6,002.4 | 4,584.5 | **6,422.6** |
| 512 | 6,858.7 | 6,302.0 | 4,103.3 | **6,925.4** |

The unit is output tok/s. NVFP4 beats FP8 at every concurrency level, by a factor of 1.07x to 1.32x, with the widest gap at concurrency 8. W4A16 does the opposite: it loses to FP8 at every concurrency level, landing at 0.75x to 0.84x of FP8's throughput.

Above concurrency 256, all four precisions have already rolled over, so the multiplier gets compressed toward 1.0. Do not treat numbers from that range as the headline.

The gap widens further on energy. At concurrency 128, tokens per joule is 12.82 for NVFP4 and 9.48 for FP8, a 1.35x gap that is larger than the 1.22x throughput gain measured at the same point. That is because 4-bit does not just cut compute, it cuts memory traffic too.

## Cutting Activations Was What Decided It

The difference between the two 4-bit formats comes down to activations.

W4A16 stores only the weights at 4 bits and leaves activations at 16 bits. That means the weights have to be unpacked back to 16 bits before the actual matrix multiply happens. It genuinely saves memory, but it adds a dequantize step to the compute path. That trade still pays off when batches are small and memory bandwidth is the bottleneck, but the moment compute becomes the bottleneck, it is a straight loss.

NVFP4 drops activations to 4 bits as well. That lets Blackwell's FP4 tensor cores consume the values directly and compute on them. There is no unpacking step. This is where the spec sheet claim, that B200's peak FP4 throughput is double FP8's, actually gets cashed in.

So the claim that "4-bit buys you capacity, not speed" is only half true. It holds for W4A16 and it is false for NVFP4.

## Quality Does Not Distinguish Any of the Four

You should not pick a precision on speed alone, so we ran the full 164-problem HumanEval set through the same harness. pass@1 came out to 0.9207 for bf16, 0.9146 for FP8, 0.9268 for W4A16, and 0.9024 for NVFP4. The standard error on each is around 0.021, while the full spread across all four is only 0.024, which means none of the differences are significant.

There is something we need to state honestly here. **NVFP4 scored numerically lowest of the four.** The z-score against bf16 is -0.58, a size this test's power cannot distinguish from noise, but that is not grounds for claiming NVFP4 quality is somehow better either. The claim we can actually defend stops at: no measurable loss.

Whether the harness ran correctly is something bf16 tells us. Here it came out to 0.9207, and the same model measured on a different day with a different harness came out to 0.9267. A 0.6-point gap is well within noise.

## If 4-Bit Comes Out Slow, Check the Benchmark First

We ourselves carried a measurement for a while that said NVFP4 was not fast. The kernel was fine. The way we were measuring it was wrong.

The biggest cause was prompt length. At 29 tokens there is almost no prefill, so we were effectively measuring decode only, but the range where 4-bit wins is where compute is the bottleneck. The workload never touched the range where it could actually win.

The GPU was also never saturated. Utilization swung between 54 and 85 percent, and we read the flat results that came out of that state as a hardware ceiling. It was not a ceiling. It was a floor.

Last, we only measured each candidate once. When we reran the same checkpoint later, the rerun variance turned out to be larger than the difference between candidates. It was never data that could rank anything in the first place.

## Do Not Ask Which Kernel Path Ran, Check It

Loading an NVFP4 checkpoint does not guarantee you are actually running on the FP4 tensor cores. If the conditions are not met, vLLM silently falls back to weight-only Marlin emulation. That path keeps the weights compressed to 4 bits but runs the compute back at a higher precision, so any number you measure in that state is the emulation's performance, not NVFP4's.

The server startup log prints which backend it picked, in one line.

```
INFO nvfp4.py:285 Using 'FLASHINFER_TRTLLM' NvFp4 MoE backend out of potential
backends: ['FLASHINFER_TRTLLM', 'FLASHINFER_CUTLASS', ..., 'MARLIN', 'EMULATION'].
```

If `MARLIN` shows up there, or if the warning below appears alongside it, throw out that run's numbers.

```
WARNING marlin_utils_fp4.py Your GPU does not have native support for FP4
computation but FP4 quantization is being used.
```

We changed things so our bench script parses this line itself instead of relying on a human to read it, and fails the run outright if the backend is not native. If the information just sits somewhere in the log for someone to find later, you miss it. We missed it. That is why we changed it.

One more thing. Do not use this log line to decide whether a checkpoint is FP4. Dense models never print the MoE backend line at all, so if you feed in a genuine NVFP4 dense build, this check reads it as "not an FP4 checkpoint" and lets it through. That decision has to come from the checkpoint's `config.json`.

## Where This Does and Does Not Apply

This does not carry over to Hopper. H200 and H100 do not have FP4 tensor cores, so vLLM takes the Marlin path. Load the same NVFP4 checkpoint on an H200 and it runs 15 percent slower than bf16. What NVFP4 buys you there is not speed, it is fit: a model that used to need two cards now fits on one.

The measurement itself has clear boundaries too: one model, one GPU, one workload shape. Change the batch composition or the context length and the multipliers will change.

## Summary

If you are targeting Blackwell, NVFP4 is the default 4-bit choice. Quality is indistinguishable from FP8, speed is 1.07x to 1.32x faster, tokens per joule is 1.35x, and size is 58 percent of FP8. There is no axis where it loses.

There is still a spot where W4A16 wins. Its file is a bit smaller, and it also runs on Hopper. But if you picked W4A16 chasing speed, that choice missed. This is not a gap you can close by tuning the kernel, it is a structural gap that comes from not cutting activations.

The numbers in this piece are real measurements taken on a single B200 with vLLM 0.27.1, not a simulation.

## Sources

- vLLM Project, [Quantization Support Overview, vLLM Docs](https://docs.vllm.ai/en/latest/features/quantization/index.html)
- vLLM Project, [vllm-project/vllm, GitHub](https://github.com/vllm-project/vllm)
- NVIDIA, [Blackwell Architecture](https://www.nvidia.com/en-us/data-center/technologies/blackwell-architecture/)
- Qwen Team, [Qwen3-Coder-30B-A3B-Instruct Model Card, Hugging Face](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)
- Chen et al., [Evaluating Large Language Models Trained on Code, arXiv:2107.03374](https://arxiv.org/abs/2107.03374)
- NVIDIA, [TensorRT Model Optimizer, GitHub](https://github.com/NVIDIA/TensorRT-Model-Optimizer)
