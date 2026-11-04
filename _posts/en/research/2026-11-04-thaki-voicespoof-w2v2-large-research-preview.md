---
title: "We Built a Model That Tells AI-Generated Voices Apart: VoiceSpoof's Performance and Where It Could Fit in Maxis, Metis and Paxis"
seo_title: "Thaki-VoiceSpoof-W2V2-Large: Voice Deepfake Detection Research Preview - ThakiCloud"
seo_description: "We released a ~300M-parameter model that separates real recordings from synthetic and converted speech as a Research Preview. Sealed ASVspoof 5 Eval: EER 8.06%, minDCF 0.1995. The reload-parity gate G5 failed under its original criterion. Only the verified BF16 runtime is supported."
excerpt: "We released a voice deepfake detection model as a Research Preview. This post covers its performance, what failed in the release checks and why, and how it could be used in Maxis, Metis and Paxis, along with what we have not verified."
date: 2026-11-04
last_modified_at: 2026-11-04
tags:
  - voicespoof
  - deepfake-detection
  - anti-spoofing
  - asvspoof5
  - wav2vec2
  - bf16
  - reproducibility
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/thaki-voicespoof-w2v2-large-research-preview/"
---

AI-generated voices are getting harder to tell apart from human recordings. A voice heard at a call center, an approval request received by phone, or an instruction given to a voice agent may now need to be checked: is this a real person speaking?

If a voice deepfake detector gives a high score, how far can you trust that result before acting on it?

To study this question, ThakiCloud trained **Thaki-VoiceSpoof-W2V2-Large** and released it on Hugging Face as a [Research Preview](https://huggingface.co/ThakiCloud/Thaki-VoiceSpoof-W2V2-Large). It is a speech classifier of about 300M parameters that separates genuine recordings (*bona fide*) from synthesized or converted speech (*spoof*).

On the sealed ASVspoof 5 evaluation set of 680,774 utterances it reached **EER 8.06% and minDCF 0.1995**. On the hardest attack, though, about one fake voice in four was accepted as genuine. And in the last check before release, we found that reloading the same weights changed scores very slightly. That check failed under its original criterion, and the failure stays on the record.

This post covers performance first, then what failed in the release check and why. After that it looks at possible uses in the order **Maxis (training) → Metis (inference) → Paxis (task execution and approval)**.

*Status as of November 4, 2026: released as a Research Preview (revision `093c7a1`). G3, G4 and G6 passed. G5 failed under its original criterion and that verdict was not changed. The release is not a G5 pass; it is a separate exception approved only for the verified BF16 runtime (REX-1–5 passed). Metis production deployment and Paxis automated execution were not approved. The Metis and Paxis material below is a reference design; end-to-end integration has not been verified.*

## 1. What the model decides

The input is speech and the output is a single score: the bona fide logit minus the spoof logit. If the score is above the threshold fixed on Dev, `τ_dev = 19.25`, the clip is classified as genuine.

The model asks one question: "Is this audio closer to a real recording, or to synthesized or converted speech?"

What it can and cannot do is clear-cut. It separates the patterns of real and spoofed speech defined by this research, under fixed evaluation conditions. It cannot tell who the speaker is, whether what they say is true, or whether they are authorized to approve a transaction. We have not measured performance on Korean synthetic speech or dialects, real telephone networks and microphones, varied input lengths, or real-time streaming.

The backbone is Meta's Wav2Vec2-Large. The XLS-R 300M model we first planned to use was pretrained on MLS, which does not fit the ASVspoof 5 Open Condition rules, so we dropped it before training. We changed the backbone to keep a data lineage that is valid for the evaluation, not to chase a score.

## 2. Performance: 70.1% better, but not a same-condition match

We trained on the official Train set (182,357 utterances), selected the model on Dev (140,950 utterances), and with that selection frozen evaluated once on the sealed Eval set (680,774 utterances). The baseline is the official AASIST weights, re-scored with the same evaluation function.

| Metric | AASIST baseline | Thaki VoiceSpoof |
|---|---:|---:|
| Training resource condition | Closed | Open |
| Dev EER | 15.20% | **4.07%** |
| Dev minDCF | 0.3147 | **0.1045** |
| Sealed Eval EER | 28.11% | **8.06%** |
| Sealed Eval minDCF | 0.6674 | **0.1995** |

Eval minDCF was 70.1% lower than AASIST. Resampling both models paired by the 737 speakers 2,000 times gave a 95% confidence interval for the minDCF difference of [−0.4843, −0.4516], and a relative improvement of [68.7%, 71.5%]. Both preregistered gates (at least 10% improvement, CI upper bound below 0) passed.

The two systems used different resource conditions. AASIST is Closed Condition; our model is Open Condition with external LibriSpeech pretraining. So we do not claim that "Wav2Vec2 beats AASIST by 70% on the same data" or "best on ASVspoof 5". This is a comparison of two systems under this evaluation protocol.

### Weaknesses the average hides

At the fixed threshold, spoof acceptance differs a lot by attack.

| Attack | Spoof acceptance | EER on that attack |
|---|---:|---:|
| A28 | **25.9%** | 14.2% |
| A19 | **21.4%** | 12.3% |
| A27 | **21.4%** | 11.3% |
| A31 | **20.0%** | 11.5% |

There are errors in the other direction too. Through codecs C07, C10 and C09, genuine human speech was rejected as fake 13.9%, 14.3% and 12.9% of the time.

Calibration is also weak: Cllr is 5.09 on Dev and 8.28 on Eval. The score is not a calibrated probability or a validated log-likelihood ratio, so it should only be used with the fixed threshold.

## 3. What failed in the release check: same weights, slightly different scores

The pre-release G5 check reloads the frozen weights in a fresh process, scores 5,000 Dev utterances, and compares them with the scores the training run saved. The criterion was a maximum difference of at most `1e-3` and decision agreement of at least 99.9%.

The result was **FAIL**. Decision agreement was 100%, but the maximum difference was 0.125. We did not change the original criterion, and this FAIL is not erased.

One read-only diagnosis narrowed down the cause.

- Only 2 clips actually scored differently, each by one bf16 step (0.125). The other 4 flagged rows were decimal rounding in the reference score file.
- Both clips were in the last batch of 8 left over after splitting 5,000 clips into batches of 128. The training run had scored the same clips inside a full batch of 128.
- Re-scoring with the same 128-row batch layout reproduced the reference scores exactly. Three independent processes gave bit-identical results.
- Weights, input tensors and compute path matched the training path.

The conclusion: this was not random GPU nondeterminism but a **bf16 numerical difference that depends deterministically on batch shape**. The diagnostic code's rule output was `IMPLEMENTATION_DEFECT`, triggered only by two metadata fields in the config (`_name_or_path` and the `dtype` label). The final causal assessment is `BF16_NUMERICAL_VARIATION_SUPPORTED`, with the root cause `DETERMINISTIC_BATCH_SHAPE_SENSITIVITY`. Both verdicts are kept on record.

The diagnosis also showed something bigger: scores move more than you might expect when the numerical environment changes.

| What changed | Score change (first 5,000 Dev clips) | Decision agreement |
|---|---|---:|
| Batch shape (bf16) | one bf16 step | 100% |
| Attention kernel (flash / mem-efficient / math instead of cuDNN) | up to 3.61 / 3.51 / 1.54 | 100% / 99.98% / 100% |
| fp32 (TF32 on or off) or fp16 | up to about 8.9 | 99.46% (27 flips) |

Running in fp32 does not give the same results. The model was trained and evaluated with bf16 autocast, so the published numbers hold only under that condition. We do not claim equivalence with fp32.

So we separated the release decision from G5. Instead of loosening the 1e-3 criterion to 0.125, we approved a separate release exception that **names the verified runtime and refuses to run outside it**. The conditions are a B200 GPU, bf16 autocast, cuDNN attention, a fixed 128-row batch (short batches are zero-padded and the padded rows discarded), and torch 2.9.0+cu130 / CUDA 13.0 / cuDNN 9.13 / transformers 4.57.6. In any other environment the inference code raises `UnsupportedRuntimeError`. We verified this policy separately. With irregular request sizes such as 1, 7, 128, 300, 33 and 512, both the 5,000-clip G5 subset and a separate 10,240-clip Dev set reproduced the training-run scores within the 8-decimal rounding of the reference file (max 5e-9), with every decision identical. Two independent processes gave bit-identical results, and all 17 unsupported environments we tried (fp32, TF32, other attention kernels, CPU, other GPUs and versions) were rejected. This verification supports the release exception only; it does not change the G5 FAIL.

The 680,774 sealed Eval utterances were not re-scored under this policy. The Eval numbers in section 2 are the original sealed evaluation, measured once before the policy existed. On Dev the fixed-policy scores matched the training run, but we did not re-check whether they match on Eval.

After the release we downloaded the model from Hugging Face again without a token and checked it. The checkpoint sha256 and τ_dev (19.25) matched the published values. All 10 runtime conditions outside the verified environment (B200, bf16 autocast, cuDNN SDPA) were rejected with `UnsupportedRuntimeError`, and the supported path gave the same result after those tests. Re-scoring the 15,360 Dev utterances in that environment gave a maximum difference of 5×10⁻⁹ from the training-run scores, inside the 1×10⁻⁸ limit, and the τ_dev decision matched on all 15,360.

## 4. The Maxis view: leaving evidence matters more than training

Maxis is ThakiCloud's training and fine-tuning area. This study is an example of the reproducible development process Maxis aims for. The results come from research GPU jobs; they do not mean end-to-end integration with the Maxis product UI.

We checked the data first. The MD5 of all 18 official tar files matched, and there were 0 exact duplicates between Train and Dev. Eval audio and labels were sealed separately.

We also kept the gates that failed. In the first smoke run, warmup put the backbone learning rate at `1e-8`, so the fp32 change in two LayerNorm weights was not visible at the first step. All 41 tensors under check received non-zero, finite gradients. After diagnosing the cause, we split the measurement into a first-step gradient check and a 150-step cumulative update check, and the amended G1 passed on one rerun. The original FAIL was not erased.

| Item | Result |
|---|---|
| GPU | 1× NVIDIA B200 |
| Training | 6 epochs, 34,188 steps, about 45 minutes |
| Non-finite steps | 0 |
| Selected checkpoint | epoch 5 |
| Dev minDCF | 0.1045 |
| Frozen threshold | `τ_dev = 19.25` |

On the sealed Eval, ties among bf16 scores also stopped the statistics step once. We left the saved raw scores untouched, fixed the code to expand the bootstrap samples and call the official evaluation function, and recorded the recovery separately.

The G5 failure was handled the same way: keep the failure on record, narrow the cause in one pass, and write any new decision as a separate record. A model can be reproduced and audited only if data provenance, training environment, checkpoint, independent evaluation and release gates connect end to end. Finishing training is not a reason to release a model or put it into service.

## 5. The Metis view: an inference contract that includes the runtime

Metis is the inference and serving area. VoiceSpoof does not generate text, so in Metis it belongs on a dedicated audio-classification endpoint, not a chat LLM endpoint.

The flow we have in mind: audio input → format and permission checks → fixed preprocessing → VoiceSpoof inference → score → a response carrying the version and threshold.

The response should carry more than a `real/fake` label: model ID, checkpoint SHA, preprocessing version, score direction, threshold and quality warnings. What G5 taught us adds one more item: **the numerical runtime has to be part of the contract.** If the GPU type, precision, attention kernel or batch policy changes, the same weights can give different scores. When the runtime does not match the contract, it is safer to reject the request than to return a different score silently. The inference code we released works that way.

Measuring model inference alone on a B200, for 4.04-second clips: p50 11.6 ms at batch size 1, p50 16.1 ms at batch size 32, and 3.18 GiB peak VRAM. Those are raw-model numbers, before padding to 128. The released code uses the fixed 128-row batch policy, so even a one-clip request is computed as a 128-row batch. On the same B200, a one-clip request took p50 53.5 ms, a 128-clip request p50 52.6 ms, with 9.14 GiB peak VRAM during scoring. Getting reproducible scores costs about 4.6× in single-request latency.

These are not end-to-end phone-call latencies. They exclude audio capture, resampling, network, queueing and post-processing. Input is also fixed at 16 kHz and 64,600 samples, so telephone resampling, padding of short audio, splitting of long audio and streaming each need separate checks against the research code. We did not measure throughput, concurrency or failure behavior. End-to-end integration with Metis serving has not been verified, and Metis production deployment has not been approved.

## 6. The Paxis view: deepfake detection is not an execution permission

Paxis is the agent platform for tool execution, workflows, policy and approval.

Here is one scenario for VoiceSpoof. If synthetic speech is suspected in an approval request or a call-center change request that arrived by voice, the agent does not run the follow-up task right away; it routes the case to additional verification or to a reviewer.

| Layer | Role |
|---|---|
| VoiceSpoof | Real-vs-spoof classification score |
| Metis | Inference service with preprocessing, version, runtime and score contract |
| Paxis | Permission checks, human approval, tool execution and audit records |

The flow: voice-based task request → VoiceSpoof detection → task policy and separate authentication → reviewer check → approved tool execution or rejection → audit record. This is a reference design, not a finished Paxis Mission.

A high bona fide score does not prove the speaker's identity, the truth of what was said, or task authority. A low score may be a codec causing a genuine voice to be rejected. Detection should serve only as supporting evidence; execution rights belong to separate policy and human approval.

A real integration would need to track more than EER: the share of genuine users sent to review, the number of wrongly approved tasks, reviewer handling time, policy violations and the completeness of audit records. We have not measured these end-to-end outcomes, and Paxis integration has not been verified. Integration that executes tasks automatically from the detection score has not been approved.

## 7. Summary

Maxis turns data and experiments into a reproducible process, Metis serves verified weights under an inference contract that names the runtime, and Paxis handles model output inside policy and approval procedures. The three platforms do not do each other's jobs. They split the work of knowing what the model knows and does not know, how its results are delivered, and under what conditions they lead to action.

In this study, performance was measured on the ASVspoof 5 Eval set. The failures and later amendments in training and evaluation, and the failure in the release check, are all on record. Real telephone-network performance, generalization to Korean, other runtimes such as fp32, and integration with Metis serving and Paxis workflows have not been verified.

The current status is **released as a Research Preview, original G5 FAIL kept**. The first screen of the [model card](https://huggingface.co/ThakiCloud/Thaki-VoiceSpoof-W2V2-Large) states the verified runtime and the rejection behavior outside it, inference cost, performance limits and evaluation history, and the repository includes the inference code, license and data-source notices. We did not upload ASVspoof 5 source audio, per-utterance labels or speaker information. Korean-language spoof detection has not been independently validated.

---

*References: ASVspoof 5 Evaluation Plan, the official ASVspoof 5 code and AASIST, and the Meta Wav2Vec2-Large model card. Numbers come from internal G3–G6 verdicts and the G5 root-cause diagnosis record as of November 4, 2026, not from an official leaderboard ranking.*
