---
title: "ThakiOCR-Large-27B-R2B: We Fine-Tuned Qwen 27B for Korean Word OCR and Released It"
seo_title: "Korean OCR fine-tuning on Qwen 27B: ThakiOCR-Large-27B-R2B released | ThakiCloud"
seo_description: "We released ThakiOCR-Large-27B-R2B under Apache-2.0, a LoRA adapter that fine-tunes Qwen3.6-27B for Korean word OCR. On a fixed 2,400-crop development set, word CER fell from 18.04% to 6.01%. Evaluation scope, GPU memory, error types, and what we have not measured yet."
excerpt: "We trained a LoRA adapter on a 27B vision-language model to read Korean word images. What improved, and where the verified scope ends, in numbers."
date: 2026-11-07
tags:
  - ocr
  - thakiocr
  - model-release
  - korean
  - qwen
  - lora
  - korean-ocr-fine-tuning
  - huggingface
permalink: /en/research/thakiocr-large-27b-r2b-qwen-korean-ocr/
categories: [research, product]
author_profile: true
toc: true
toc_label: "Contents"
toc_sticky: true
reading_time: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/thakiocr-large-27b-r2b-qwen-korean-ocr/"
---

We released a research model that transcribes images of Korean words into text. It leaves a large vision-language model as it is and adds a small extra trained file on top. Compared with the original model using the same instruction, character errors dropped sharply.

When reading Korean words in uneven condition, such as handwritten application forms or photos taken on site, the original model often added characters that were not there. This training reduced that habit. Errors on digits and Latin letters also fell, but we did not separately measure parts where format matters, such as amounts. The verified scope, however, ends at reading one word image, and we have not yet measured reading whole documents.

The release is called [ThakiOCR-Large-27B-R2B](https://huggingface.co/ThakiCloud/ThakiOCR-Large-27B-R2B). It is a LoRA adapter for Qwen3.6-27B, licensed under Apache-2.0. On a fixed development set of 2,400 crops, the base model had a word CER of 18.04%. With this adapter attached, CER drops to 6.01%. It reads one word crop at a time, and it is a research preview, not a product release.

## In plain terms

Show a strong reader an unfamiliar handwritten note one word at a time and they will make mistakes. Often the problem is not that they cannot recognize the letters but that they add letters that are not there. This adapter is what you get after walking that reader through 12,800 handwritten, printed, and photographed word cards, once each, with one instruction: write down only the letters you see. The reader stays the same and only the habit changes, so we ship it as a small adapter file that sits on top of the base model.

## The problem

Enterprise document processing has to turn Korean images of very different quality into text: handwritten application forms, printed forms, signs and labels photographed on site. Large vision-language models are good at describing image content, but before fine-tuning they made many errors when transcribing Korean handwritten words. In our measurement, the Qwen3.6-27B base model had a CER of 37.77% on handwritten words (91 handwriting).

The research asked two questions.

1. If we train only a LoRA on the decoder of a 27B model for word OCR, do errors drop compared with the base model?
2. Does training that draws words with rare characters more often (R2-B) beat training that draws uniformly (R2-A)?

## Model, data, and training

The base model is `Qwen/Qwen3.6-27B` (revision `6a9e13bd6fc8f0983b9b99948120bc37f49c13e9`, Apache-2.0). The release is a LoRA adapter for this model and does not include the base weights.

| Item | Value |
|---|---|
| Method | LoRA r=32, alpha=64, dropout 0.05, on 496 decoder linear layers (attention and MLP) |
| Frozen | Vision encoder and vision-language merger |
| Trainable parameters | 233.5M |
| Training | 800 steps, learning rate 1e-4, warmup 100, AdamW, effective batch 16 (2 GPUs × 8 accumulation) |
| Images seen | 12,800, each at most once. 605 3,840 · 91 handwriting 3,840 · 91 printed 1,920 · 105 3,200 |
| Sampling (R2-B) | Weighted draw without replacement within each source. Weight 1 to 2 by rank of the word's mean character rarity (frequencies from the training split only) |
| Compute | About 3.37 GPU-hours on NVIDIA B200 |
| Adapter file | `adapter_model.safetensors`, 933,974,032 bytes |

Training data came from three application-based datasets on AI-Hub, cut into word crops. After de-duplication the training pools were 149,980 crops (91 handwriting), 119,361 (605), 20,927 (91 printed), and 33,105 (105). The data and anything derived from it (crops, label files, subsets, samples) are not released and do not appear in this post.

- AI 허브(AI-Hub) — 대용량 손글씨 OCR 데이터 (605), large-scale handwriting OCR data
- AI 허브(AI-Hub) — 다양한 형태의 한글 문자 이미지 인식 데이터 (91), Korean character images in various forms
- AI 허브(AI-Hub) — 야외 실제 촬영 한글 이미지 데이터 (105), Korean text photographed outdoors

## Performance against the baseline

**Baseline**: the same Qwen3.6-27B without fine-tuning, with the same prompt (`이미지에 적힌 글자를 그대로 옮겨 적으세요. 글자만 출력하세요.`, "Transcribe the text in the image exactly. Output only the text.") and the same decoding settings. R2-A is a reference adapter trained under the same conditions with uniform sampling only.

**Evaluation set**: 2,400 word crops, 600 per source, drawn from the official Validation splits of the three datasets used for training. All three models were measured on the same 2,400 crops. Because it comes from the same datasets as the training data, it is not an independent test set.

**Metric**: word CER, the total number of character edits divided by the total number of ground-truth characters, after Unicode NFC normalization and whitespace strip. Lower is better.

| Model | All (2,400) | 91 handwriting | 605 handwriting | 91 printed | 105 scene text |
|---|---|---|---|---|---|
| Qwen3.6-27B base (same prompt) | 18.04% | 37.77% | 23.76% | 6.54% | 10.38% |
| R2-A adapter (uniform sampling, reference) | 6.42% | 12.19% | 6.31% | 2.23% | 6.71% |
| **R2-B adapter (this release)** | **6.01%** | 12.27% | **5.53%** | **1.61%** | 6.57% |

Exact-match rate (whole word correct): base 72.7%, R2-A 84.0%, R2-B 85.2%.

The decision rules were pre-registered before we saw results. The 95% confidence intervals come from a paired bootstrap stratified by source over the 2,400 IDs, with 2,000 resamples.

- R2-B vs base, all sources: −12.03 pp [−14.88, −9.73]. None of the four sources got worse.
- R2-B vs R2-A, all sources: −0.41 pp [−0.82, −0.03]. It passes the pre-registered criterion, but the upper bound is close to zero. In a sensitivity analysis that drops 274 near-duplicate candidates, the upper bound is 0.0. We therefore read the extra gain from rare-character sampling as weak.
- On 91 handwriting, R2-B is not better than R2-A (+0.08 pp, writer-cluster interval [−0.89, +0.92] pp).

We also checked for leakage. Train and evaluation share zero files by file hash, decoded-pixel hash, and source-image hash, and no 91-handwriting writer appears in both. Training images close to evaluation candidates (dHash ≤ 4 and pHash ≤ 8) were removed from training. The step-800 checkpoint was fixed in advance.

## Error types and limits

The error diagnostics are descriptive only, without confidence intervals. We describe error types and rates and do not quote any source text or image.

**The base model's main error was adding characters.** On 91 handwriting, the base model had 19.19% substitutions, 18.59% insertions, and 0 deletions. After fine-tuning, insertions almost disappeared (R2-A 0.08%, R2-B 0.15%), while substitutions stayed at 12.11% for both adapters. On 91 handwriting, most of the gain came from no longer inventing characters. Picking the wrong look-alike character is still there.

**Digits and Latin characters improved the most.** Pooled CER by character class is below, computed after projecting both reference and prediction onto that class.

| Character class | Base | R2-A | R2-B |
|---|---|---|---|
| Digits | 6.81% | 1.45% | 0.77% |
| Hangul | 12.71% | 7.26% | 7.00% |
| Latin | 25.18% | 7.91% | 5.76% |
| Punctuation | 19.17% | 4.89% | 4.51% |

R2-B's gain over R2-A came mainly from digits, Latin characters, and characters seen 5 to 49 times in training. There was no visible difference on characters seen 4 times or fewer, and with only 60 occurrences we cannot draw a conclusion.

**Checks for misread numbers and amounts stop here.** The digit CER above is for digit characters inside word crops. We did not separately measure amount formats (commas, the won sign, units), date formats, or exact match of whole digit strings with this adapter. Workflows that handle amounts need separate checks, such as format validation or totals reconciliation, and we have not measured their effect yet.

**Not verified**

- It reads one word crop. Full pages, lines and paragraphs, tables, layout, and reading order were not evaluated.
- The evaluation set comes from the same datasets as training. We do not know whether performance holds on new document types or new capture conditions.
- 91 printed uses the same 10 fonts in training and evaluation. It is not a font-generalization result.
- 91 handwriting has 15 evaluation writers, none seen in training. With so few groups, writer-level intervals are wide.
- 605 and 105 have no group key, so group-level generalization is not shown.
- We did not compare against specialist OCR models under the same conditions and do not claim to be better than them.
- English-only and mixed Korean-English inputs were not measured on their own.

## What we know and do not know for operations

| Question | Current evidence |
|---|---|
| GPU memory | About 53 GB in bf16 at batch 1, per the model card. In a separate study (R3-0, B200) with the R2-A adapter on the same base model, peak VRAM was 52.1 to 52.4 GiB |
| Hardware tested | NVIDIA B200 (evaluation, latency), H200 (post-release load and inference smoke test) |
| Latency | About 0.46 s median per crop on one B200 at batch 1, per the model card. Internal measurement, not a serving benchmark |
| Throughput, concurrency, cost | Not measured yet |
| Smaller GPUs, quantization, merged checkpoint | Not measured yet. Only adapter inference was measured. A merged checkpoint may not be bit-identical to adapter inference |

**On-premises operation** is possible as far as licensing and packaging go. Both the base model and the adapter are public Apache-2.0 weights, and the base model repository does not require access approval. If you download both and run them on your own GPU servers, the images you process do not have to leave your environment. We have not measured behavior or performance on hardware other than what is listed above.

## Download and inference

Use the settings below exactly. Other prompts, image sizes, and sampling settings were not evaluated. The base model's `generation_config.json` enables sampling by default, so pass `do_sample=False` explicitly.

| Setting | Value |
|---|---|
| Base model | `Qwen/Qwen3.6-27B`, revision `6a9e13bd6fc8f0983b9b99948120bc37f49c13e9` |
| Prompt (Korean, verbatim) | `이미지에 적힌 글자를 그대로 옮겨 적으세요. 글자만 출력하세요.` |
| Chat template | one user turn: image, then prompt; `add_generation_prompt=True`, `enable_thinking=False` |
| Image size limits | `min_pixels = 64*64`, `max_pixels = 1024*1024` |
| Decoding | greedy (`do_sample=False`), `max_new_tokens=64`, batch 1 |
| Precision | bf16 |

```bash
pip install torch "transformers>=5.0" "peft>=0.21" pillow
python inference_example.py --image word.png            # prints the transcription
python inference_example.py --image word.png --report   # JSON: text + load checks
```

The repository's `inference_example.py` pins the base revision and checks that 496 LoRA modules were attached and that none of them sit in the vision tower. The core of it:

```python
import torch, transformers
from peft import PeftModel
from PIL import Image

base = "Qwen/Qwen3.6-27B"; rev = "6a9e13bd6fc8f0983b9b99948120bc37f49c13e9"
processor = transformers.AutoProcessor.from_pretrained(base, revision=rev)
model = transformers.AutoModelForImageTextToText.from_pretrained(base, revision=rev, dtype=torch.bfloat16).to("cuda")
model = PeftModel.from_pretrained(model, "ThakiCloud/ThakiOCR-Large-27B-R2B").eval()

msgs = [{"role": "user", "content": [{"type": "image"},
         {"type": "text", "text": "이미지에 적힌 글자를 그대로 옮겨 적으세요. 글자만 출력하세요."}]}]
prompt = processor.tokenizer.apply_chat_template(msgs, tokenize=False, add_generation_prompt=True, enable_thinking=False)
inputs = processor(text=[prompt], images=[Image.open("word.png").convert("RGB")], return_tensors="pt",
                   images_kwargs={"min_pixels": 64 * 64, "max_pixels": 1024 * 1024}).to("cuda")
out = model.generate(**inputs, max_new_tokens=64, do_sample=False)
print(processor.tokenizer.decode(out[0, inputs["input_ids"].shape[1]:], skip_special_tokens=True).strip())
```

After release, we downloaded the adapter without logging in and confirmed its hashes match the original. We then ran the public example code unchanged and confirmed that it reads one synthetic image we rendered ourselves (not AI-Hub data) correctly.

## Using it on the platform, and how to reach us

ThakiCloud builds a platform for training models (Maxis), serving them (Metis), and connecting them to work (Paxis) in environments the customer controls. This adapter went through the same process: data lineage records, pre-registered evaluation, queue-based GPU training, hash verification, and reproduction from an anonymous download. For technical questions about deploying it on your own GPUs or re-evaluating it on your own documents, contact [ThakiCloud](https://thakicloud.com).

## Related posts

Research on the same Korean word OCR task with a much smaller model is in the [ThakiOCR-KO-v1 post](/tech-blog/en/research/thakiocr-ko-v1-ovisocr3-korean-finetune/). The two posts use different evaluation sets and measurement conditions, so their numbers are not a ranking.

- [ThakiOCR A: a 2.13M-parameter Korean-English line OCR](/tech-blog/en/research/thakiocr-a-small-korean-english-line-ocr/)
- [ThakiOCR G2M: the second release, reading digits and symbols more accurately](/tech-blog/en/research/thakiocr-g2m-numbers-and-symbols/)
- [ThakiOCR A2: improvements and remaining limits on a 43,751-line independent evaluation](/tech-blog/en/research/thakiocr-a2-independent-eval-43751-lines/)

## References

- Model: [ThakiCloud/ThakiOCR-Large-27B-R2B](https://huggingface.co/ThakiCloud/ThakiOCR-Large-27B-R2B) (Apache-2.0)
- Base model: [Qwen/Qwen3.6-27B](https://huggingface.co/Qwen/Qwen3.6-27B) (Apache-2.0)
- Training data: AI-Hub 605 · 91 · 105. Data redistribution is not permitted; used internally by the approved applicant only. To use the data, apply for it yourself on AI-Hub.
- This is a research release. Any product release decision is separate.
