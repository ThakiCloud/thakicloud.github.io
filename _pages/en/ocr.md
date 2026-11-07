---
title: "ThakiOCR Models"
layout: posts
permalink: /en/ocr/
lang: en
default_tag: thakiocr
author_profile: true
sitemap: true
---

This page collects the four OCR models ThakiCloud has published on Hugging Face. All four are research releases, not product launches. They differ in input unit, required hardware, and evaluation setup, so the numbers below are not a ranking between models.

## In plain terms

The four models are different tools in the same toolbox. A small screwdriver fits in a pocket and can be used thousands of times a day; a power drill is heavy but goes through a hard wall. The useful question is not which tool is better, but which one fits the job in front of you.

## At a glance

This table covers size and use only. Performance numbers are listed per model below, each with its evaluation contract.

| Model | Size | Input unit | Runs on | Release status | License |
|---|---|---|---|---|---|
| ThakiOCR-KOEN-V1-Dense | 2.13M parameters | one text line (Korean, English) | CPU | research release | Apache-2.0 |
| ThakiOCR-KOEN-G2M-Preview | 8.93M parameters | one text line (Korean, English) | CPU | research preview, A1_GEN2_NO_GO | Apache-2.0 |
| ThakiOCR-KO-v1 | 0.9B-class base model + 6.39M LoRA parameters | one Korean word image | GPU | research preview | Apache-2.0 |
| ThakiOCR-Large-27B-R2B | 27B base model + 233.5M LoRA parameters | one Korean word image | GPU (about 53GB in bf16) | research preview | Apache-2.0 |

KO-v1 and Large-27B-R2B are released as LoRA adapters only. The base models (ATH-MaaS/OvisOCR3, Qwen/Qwen3.6-27B) must be downloaded separately at the pinned revision given on each card.

## Model cards

The evaluation sets and metrics on these four cards differ, so the numbers are not a ranking between models. Each number is listed together with the conditions it was measured under.

### ThakiOCR-KOEN-V1-Dense

- **Size**: 2,130,249 parameters. About 1.83M of them sit in the final layer that outputs 14,152 characters.
- **Use**: a small CPU baseline that reads one cropped text line. Place it after a line detector or layout model.
- **Headline metric**: CER 37.14% on a real Korean development set, 17.81% if spaces are ignored.
- **Evaluation contract**: 5,000 word crops from part of the validation data of AI-Hub's OCR 데이터(공공) (Public OCR data, 71299), used for evaluation only. It is a development measurement, not an independent test set, scored by exact string match after greedy CTC decoding and NFC normalization. On held-out synthetic Korean lines from the same source as training, CER is 16.70%.
- **Speed**: median 5.61ms for one 512px-wide line on 4 threads of a data-center server CPU.
- **Limitation**: on 38% of real Korean word crops it inserts spaces between syllables that are not there.
- **Training data**: NVIDIA OCR-Synthetic-Multilingual-v1 (CC BY 4.0) only. No AI-Hub data was used for training.
- **License**: Apache-2.0 for both code and weights.
- **Links**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-KOEN-V1-Dense) · related post [ThakiOCR A release](/tech-blog/en/research/thakiocr-a-small-korean-english-line-ocr/)
- **Release status**: research release. Single-seed results.

### ThakiOCR-KOEN-G2M-Preview

- **Size**: 8,926,251 parameters. The same family of line-level CTC recognizer as V1-Dense, scaled up and trained again from scratch.
- **Use**: research on line recognition where symbols must survive, such as won signs, dates, circled numbers, and masked digits. Median CPU latency was 13.3ms per line.
- **Headline metrics**: CER 0.89% on text lines of a real held-out set, and 94.2% critical-token strict exact match on a self-generated symbol test set.
- **Evaluation contract**: the real held-out set is 70 lines from one volume of the Training split of AI-Hub's OCR 데이터(공공) (Public OCR data, 71299) that was kept out of training. The symbol test set is 5,991 newly generated synthetic lines with no text overlap with training. Both sets were opened once, after training, and the pre-set criteria were not changed.
- **Limitation**: of five pre-set pass criteria (preregistered gates), it failed the date criterion (I4). It got 3 of 4 real-document date tokens right.
- **License**: Apache-2.0. Training data sources are NVIDIA OCR-Synthetic-Multilingual-v1 (CC BY 4.0), in-house synthetic symbol lines rendered with SIL OFL 1.1 fonts, and the Training split of AI-Hub's OCR 데이터(공공) (Public OCR data, 71299).
- **Links**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-KOEN-G2M-Preview) · related post [G2M release](/tech-blog/en/research/thakiocr-g2m-numbers-and-symbols/)
- **Release status**: research preview, verdict A1_GEN2_NO_GO. Do not use it to process critical fields such as amounts, account numbers, or dates in financial or contract documents automatically.

### ThakiOCR-KO-v1

- **Size**: a LoRA adapter for the 0.9B-class document OCR model ATH-MaaS/OvisOCR3 (rank 16, decoder only, 6.39M trainable parameters, 25.6MB).
- **Use**: transcribes one Korean word image. It learned handwriting, printed text, and outdoor photographed text, and was selected so that it does not break the base model's table and reading-order abilities.
- **Headline metric**: on a fixed development set of 2,400 word crops, CER fell from 25.28% (base model) to 7.78%.
- **Evaluation contract**: the development set takes 600 crops per source from the official Validation splits of the three datasets used for training. It is the same source, so it is not an independent test set. Scored by CER after greedy decoding, NFC normalization, and whitespace stripping. Document structure was checked only as "no worse than the base model": exact table-structure match was 1.00 (base 0.98) on 50 synthetic table pages kept sealed until results were in.
- **Speed and memory**: median 0.210s and peak memory 7.02GiB on one B200 at batch 1.
- **Limitation**: trained and evaluated at word level only. Full-page reading quality on real documents has not been independently verified.
- **Training data**: AI-Hub's 대용량 손글씨 OCR 데이터 (large-scale handwriting OCR data, 605), 다양한 형태의 한글 문자 이미지 인식 데이터 (Korean character image recognition data in various forms, 91), and 야외 실제 촬영 한글 이미지 데이터 (Korean text images photographed outdoors, 105). The data and anything derived from it are not redistributed.
- **License**: Apache-2.0. The base model is governed by its own license.
- **Links**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-KO-v1) · related post [KO-v1 release](/tech-blog/en/research/thakiocr-ko-v1-ovisocr3-korean-finetune/)
- **Release status**: research preview.

### ThakiOCR-Large-27B-R2B

- **Size**: a LoRA adapter for Qwen/Qwen3.6-27B (rank 32, 496 decoder linear layers, 233.5M trainable parameters).
- **Use**: research on large-model OCR of one Korean word image. Training drew words with rare characters more often.
- **Headline metric**: on a fixed development set of 2,400 word crops, CER fell from 18.04% (base model) to 6.01%. Whole-word exact match is 85.2%.
- **Evaluation contract**: the development set takes 600 crops per source from the official Validation splits of the three datasets used for training and is not an independent test set. Overlap with training was ruled out by file, pixel, and source-image hashes, and scoring used greedy decoding. Confidence intervals come from a stratified paired bootstrap fixed before results were seen.
- **Hardware**: about 53GB of GPU memory in bf16 at batch 1, median about 0.46s per crop on one B200.
- **Limitation**: the extra 0.41pp gain over the uniform-sampling adapter (R2-A) is statistically borderline.
- **Training data**: the same AI-Hub datasets 605, 91, and 105 as KO-v1. The data and anything derived from it are not redistributed.
- **License**: Apache-2.0. The base model is governed by its own license.
- **Links**: [Hugging Face](https://huggingface.co/ThakiCloud/ThakiOCR-Large-27B-R2B) · related post [Large-27B-R2B release](/tech-blog/en/research/thakiocr-large-27b-r2b-qwen-korean-ocr/)
- **Release status**: research preview. No claim of superiority over specialist OCR models.

The development sets of KO-v1 and Large-27B-R2B are built in a similar way, but we have not verified that evaluation images, preprocessing, decoding, and ground-truth handling are the same. So we do not compare the two models with these numbers.

None of the four cards links a GitHub repository. Inference code ships inside each Hugging Face repository (`inference.py` for V1-Dense and G2M, `inference_example.py` for KO-v1 and Large-27B-R2B).

## Which one should I pick?

Pick by input unit and hardware, not by a numeric ranking.

- **No GPU, and you need fast line-level reading**: look at V1-Dense or G2M. Both take one line cropped by a line detector.
- **Lines where won signs, circled numbers, or masked digits matter**: look at G2M. It is weak on dates with inner spaces and on telling `₩` from `￦`, so keep a human review step.
- **You want the lightest baseline or a from-scratch architecture**: look at V1-Dense. It shows what breaks on real documents when a model learns from synthetic data alone.
- **Korean words mixed with handwriting or photographed text, on one GPU (about 7GiB)**: look at KO-v1. It is the adapter that chose to keep the base model's table-structure ability.
- **53GB or more of GPU memory, and you are studying how far a large model can learn word OCR**: look at Large-27B-R2B.

None of these models should read critical fields in financial, legal, or identity documents without human review. How to route documents to different models is covered in the [Metis tiered document inference post](/tech-blog/en/llmops/thakiocr-metis-tiered-document-inference/), and how to commit results to business systems only after verification is covered in the [Paxis verification workflow post](/tech-blog/en/agentops/thakiocr-paxis-verify-before-commit/).

## For research use

1. **Download from Hugging Face.** Each card's Files table lists weights, configuration, and inference code. For adapters, pin the base model revision given on the card.
2. **Reproduce with the card's inference code first.** Nothing outside the card's preprocessing, prompt, and decoding settings was evaluated. V1-Dense and G2M can be checked right away with `python inference.py --demo`.
3. **Read the documentation.** Failure types and evaluation set composition are in each card's Known limitations section and in the related posts. Why the four models come in different sizes is explained in [Four Open Korean OCR Models Compared](/tech-blog/en/research/korean-ocr-open-models-2m-to-27b/).

## For adoption review

1. **Define the use case.** Write down document types, input unit (line, word, page), daily volume, and the fields that must not be wrong. None of the four models finds text positions on a page, so a separate detection step is needed.
2. **Check security and on-premises conditions.** The weights can be downloaded and run inside a private network. Running training and serving inside the customer's environment is covered in the [Maxis training post](/tech-blog/en/research/thakiocr-maxis-same-size-fewer-errors/) and the [Metis tiered inference post](/tech-blog/en/llmops/thakiocr-metis-tiered-document-inference/).
3. **Send a technical inquiry.** For evaluating on your own documents or deploying on the platform, contact [ThakiCloud](https://thakicloud.com).

## In development

{: .notice--info}
**These models are in development. No performance numbers are published.**
**ThakiOCR-KO-v2**: there was not enough document and handwriting data for an independent evaluation, so the official evaluation was not run and the release is on hold. It is not on hold because of poor performance.
**ThakiSight-Edge**: training is in progress.

## Related posts

The list below shows every post tagged `thakiocr`. The main ones are:

- [ThakiOCR A: our own 2.13M-parameter Korean-English OCR](/tech-blog/en/research/thakiocr-a-small-korean-english-line-ocr/)
- [ThakiOCR G2M: our second public model, built to read numbers and symbols more accurately](/tech-blog/en/research/thakiocr-g2m-numbers-and-symbols/)
- [ThakiOCR A2: what an independent 43,751-line evaluation confirmed](/tech-blog/en/research/thakiocr-a2-independent-eval-43751-lines/)
- [Same 8.93M parameters, 31% fewer OCR errors](/tech-blog/en/research/thakiocr-maxis-same-size-fewer-errors/)
- [Tiered document inference with ThakiOCR and Metis](/tech-blog/en/llmops/thakiocr-metis-tiered-document-inference/)
- [What should an agent do when OCR misreads an amount?](/tech-blog/en/agentops/thakiocr-paxis-verify-before-commit/)
- [Four Open Korean OCR Models Compared: From 2.13M to 27B](/tech-blog/en/research/korean-ocr-open-models-2m-to-27b/)
