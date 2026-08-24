---
title: "Can the Gatekeeper Be Quantized Too: An Accuracy-Cost Experiment on Hybrid Skill Router Embedding Compression"
seo_title: "The Effect of Embedding Quantization on Skill Routing Accuracy - Thaki Cloud"
seo_description: "We measure how hit@1/hit@3/MRR and latency/memory change when the embedding model of a hybrid (BM25+embedding) router is quantized to INT8, on a 1,910-skill catalog and a 36-pair golden set, and present the break-even conditions for judging whether compression pays, plus a rank-safety margin diagnostic."
excerpt: "If you quantize half of the embeddings of a hybrid skill router that is called every turn, does accuracy drop and latency go down? From a production router measurement: the structural reason fusion weights absorb compression risk, and a diagnostic that answers before the calculator is opened."
date: 2026-08-20
last_modified_at: 2026-08-24
tags:
  - embedding-quantization
  - skill-routing
  - retrieval-accuracy
  - hybrid-retrieval
  - int8-quantization
  - cost-quality-tradeoff
  - agent-harness
  - bm25
categories:
  - research
author_profile: true
toc: true
toc_label: "Table of Contents"
---

If you keep roughly 1,600 to 2,000 skills in your agent harness and pick, every turn with a hybrid router (lexical score + embedding similarity), which skill to call, this article looks at the hidden cost structure of that router. Unlike a document search index, the router's embedding model is not something you encode once offline and are done with: it runs again every time a user speaks. How much accuracy drops and how much speed you gain if you quantize half of it, here are the results of measuring directly on a production router.

## A Search Index and a Router Have Different Cost Structures

In document search, the embedding cost is paid once, by encoding the corpus, and afterwards it is repaid as a cheap lookup over stored vectors. A router is not like that. The catalog is small and changes slowly, but the user's query has to be freshly encoded every time. In other words, the embedding model is an always-on component that holds memory and adds latency before downstream inference even begins.

Yet compression research has treated these two roles asymmetrically. The literature on quantizing generative models is thick. The compression of the retrieval model that guards the door to those generative models has been handled separately by the vector search community, and even there it takes index size and recall as its criteria, not the routing decision itself. The skill-routing literature is in a similar position. Retrievers have been things that clean inputs, re-rank outputs, and get benchmarked on failures; it is hard to find research that treats their weights themselves as a design variable. This paper connects those two severed branches, for the first time, at the router point.

## Fusion Weights Reduce Compression Risk on Their Own

The core observation comes from surprisingly simple algebra. A hybrid router's score blends the lexical score and the embedding cosine similarity by a weighted sum. The lexical score is computed from token statistics only, so it does not change by a single bit when the embedding is quantized. The only channel through which quantization error can enter is the single embedding term, and that term is reflected in the final score only to the extent of the fusion weight $(1-\alpha)$.

A first-order perturbation analysis closes this relationship with an upper bound on the score error in the closed form $2(1-\alpha)\varepsilon(b)$. Here $\varepsilon(b)$ is the value describing how much the embedding vector wobbles under a bit budget $b$. The conclusion is clear. The more a router leans on the lexical score, the structurally safer it is to compress its embedding, and a pure dense search engine ($\alpha=0$) takes the full error on itself. What is interesting is that this damping effect comes from the form of the fusion equation itself alone, independent of the encoder or the quantization scheme, or of the corpus's properties.

![Conceptual diagram: the fusion weight damps quantization risk linearly](/assets/images/posts/research/quantized-embedding-skill-router/fig3-dampening-schematic.webp)
*A conceptual example, not a measurement. It diagrams Observation 2 (the linear relation that risk is proportional to 1-alpha). It is not a graph computed from the Section 4 measured data.*

One step further yields a diagnostic usable in practice immediately. For any query, the score difference (margin) between the first-place and second-place candidates is already computed by the router, so if that margin is larger than $4(1-\alpha)\varepsilon(b)$, it can be proved that the first-place verdict for that query will never be overturned, without running the quantized encoder even once. If the fraction of queries over the whole golden set that fail to satisfy this condition is called $p_{\mathrm{risk}}(b)$, the upper bound of compression risk can be certified in advance without running the compressed encoder at all. A value of 0 means hit@1 never changes at that bit width. This certification does carry the premise that it holds only when $\varepsilon(b)$ is actually a valid bound, though.

## The Break-Even Condition for Measuring Whether Compression Really Pays

A small risk of accuracy loss does not make compression always a loss. If the expected accuracy loss (the probability of leading to a misclassification times the misclassification cost) is smaller than what is saved in latency and memory, compression is a gain in itself. One interesting implication falls out of this break-even inequality. Memory savings are an always-on cost that occurs whether requests arrive or not, so the right side grows as traffic volume $N$ grows, while the left side (accuracy loss) is a per-request risk and is independent of $N$. In other words, the busier a router is, the more easily it crosses the break-even of compression. That is the opposite of the intuition that "the busier the system, the more it stands to lose."

The previous two installments of this paper series (an attempt to readjust fusion weights with an online bandit, and model-tier ensemble voting) were both break-evens of the "must gain more accuracy to break even" improvement-goal type, and neither produced a great answer. Compression is structurally different. The gain arises in proportion to traffic, structurally, and what must be justified is not accuracy gain but accuracy loss. That the break-even becomes a risk tolerance set directly by the operator, rather than an improvement goal, is the core claim of this paper.

## What We Actually Measured on the Production Router

To check whether the theory holds, we verified against a running skill router: from its catalog of 1,910 entries and 63 pairs in the regression golden set, we selected the 36 pairs where the correct skill actually remains in the catalog. Two encoders were attached. One is the multilingual encoder `paraphrase-multilingual-MiniLM-L12-v2`. One thing to make clear here: this model is not the production encoder, but a stand-in set up in its place. What the real router serves is EmbeddingGemma-300M (`embeddinggemma-300M-qat-Q4_0.gguf`), on a GGUF inference server. The quantization tool used this time could not touch that model, so a stand-in was set up. `torch.quantization.quantize_dynamic` works by swapping PyTorch `nn.Linear` modules, and there are no such modules in a GGUF file. The role (multilingual, sentence level, the embedding lane of the same fusion router) was matched, but it is not the same model, and this is a limit to keep in mind when reading the results. The other is a small English-only encoder (`all-MiniLM-L6-v2`) attached as a control. Both were compressed in the `nn.Linear` modules only, via PyTorch's dynamic INT8 quantization.

![hit@1 accuracy by fusion method, fp32 vs INT8](/assets/images/posts/research/quantized-embedding-skill-router/fig1-hit1-by-arm.webp)
*The multilingual stand-in encoder keeps hit@1 unchanged when fused with the lexical lane, while the embedding-only lane drops. The control encoder, however, shows the opposite pattern after fusion. (2026-08-19/20 local MacBook, repo .venv, manual re-run measurement on CPU, GPU not used.)*

The results followed the theory only halfway. In the multilingual stand-in encoder, the embedding-only lane's hit@1 dropped from 0.1667 to 0.1389 (by the amount of one of the 36 queries), and MRR fell by 0.0215, but the hybrid lane fused with the lexical lane kept hit@1 and hit@3 exactly unchanged, and MRR moved by only 0.0024. About one tenth of the embedding-only change magnitude. The direction matches the prediction that fusion weights act as a damper.

In the English-only control encoder, though, it was the exact opposite. The embedding-only lane's hit@1 did not move at all, while the fused hybrid lane's hit@1 dropped from 0.25 to 0.1944 (by the amount of two queries), and hit@3 fell by the amount of one query. Far from reducing the risk, fusion had amplified it. With a sample of 36, it is too early to say with certainty, but the key may be how well the pre-compression embedding ranking agrees with the lexical ranking. At points where the two lanes already agree, the wobbled dense ranking gets corrected by the un-wobbled lexical ranking, but at points where the two lanes point to different answers from the start, the dense lane's error is passed straight into the fused result.

![Per-query single-encoding latency, fp32 vs INT8 median](/assets/images/posts/research/quantized-embedding-skill-router/fig2-latency.webp)
*On this CPU backend, single-query encoding got slower rather than faster after dynamic INT8 quantization for both encoders, so the latency term of the break-even condition was not passed. (2026-08-19/20 local MacBook, repo .venv, manual re-run measurement on CPU, GPU not used.)*

The more painful practical result came out on the latency side. Under the batch-size-1 condition, the same as the router's real workload, the stand-in encoder's per-query encoding time increased from 8.29ms to 11.15ms, and the control's from 5.31ms to 6.72ms. The time to encode the full 1,910-entry catalog in one pass at batch 32 also grew from 7.772 seconds to 21.015 seconds. The generic PyTorch dynamic quantization backend used this time shattered the very premise of compression on this hardware (Apple Silicon, qnnpack kernels). Memory savings also fell short of expectations. INT8 compresses 4x in theory, but this backend quantizes only the linear layers and leaves the embedding table as-is, so in practice the stand-in encoder shrank by only 1.16x and the control by 1.55x. The left side of the break-even inequality (accuracy risk) was not computed at all in the first place: the margin values were not stored separately, so $p_{\mathrm{risk}}(b)$ could not be verified by measurement, and the right side effectively came out negative in the latency term, which leads to the conclusion that compression is hard to justify in this combination.

The sample size of 36 queries is also worth flagging. In the stand-in encoder, there were 0 cases where the first-place verdict was overturned after fusion, but by the rule of three, when 0 events are observed in 36 trials, the upper bound that can be set at a 95% confidence level is only about 8.3%. That is not grounds to assert "the first place never changes."

## The Three-Fold Meaning This Experiment Left Behind

From the company perspective, we measured whether the embedding component of our hybrid skill router, which actually handles 1,978 exposed skills, can be compressed to reduce per-session routing latency and memory overhead while keeping hit@1/hit@3/MRR, and left behind the basis for gauging the precision floor that can be shipped safely. The fact that latency actually increased in this combination (generic PyTorch dynamic quantization + this CPU backend) is itself a signal that the assumption "just attach a quantization tool and it gets faster" must not be adopted without verification.

Socially, the meaning is that we demonstrated empirically the cost-accuracy tradeoff of compressing the small embedding models used for search and routing, not the large generative models. When reviewing paths to run agent harnesses at low cost without a GPU, it provides a basis for widening the compression target beyond generative models alone, all the way to the routing layer.

Scientifically, it fills the gap that existing quantization literature almost entirely deals with the accuracy-cost tradeoff of generative models, while the impact of quantization of retrieval/routing-only embedding models on the hybrid (lexical + embedding) fusion score has been rarely measured separately. In particular, the observation that fusion weights structurally absorb compression risk, and the diagnostic that certifies rank stability in advance without incurring any computation cost at all, are new contributions of this paper.

## What Else Needs to Be Confirmed

The biggest limit is that this measurement could not verify the diagnostic ($p_{\mathrm{risk}}(b)$) that the paper proposes. Because the margin values were not stored, they could not be computed after the fact, and the paper's central claim, "certify rank stability in advance with float32 scores alone," still stands on theory only. The next step is clear: store the margins and actually draw the $p_{\mathrm{risk}}(b)$ curve.

The second limit is the possibility of bias in the golden set itself. In these 36 queries, the lexical lane alone (hit@1 0.5278) even outperformed the two hybrid arms. That is, the share the embedding lane contributed from the start may have been small, and the selection criterion of "only picked pairs where the correct answer actually exists in the catalog" itself may have biased the sample toward the direction the lexical lane already handles well. A golden set assembled for regression testing is not a balanced search benchmark. On top of this, the experiment was confined to one quantization backend, one bit width, one piece of hardware, and one batch size. In other compression routes such as quantization-aware learning (QAT), full-precision re-scoring after binarization, or Matryoshka truncation, the sign of the latency term itself may still flip.

You can see the paper detail page here: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-20-quantized-embedding-skill-router](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-20-quantized-embedding-skill-router)

---

The first published version called the multilingual encoder above "the production encoder." That was not the case, and it was corrected on 2026-08-20. The router, the 1,910-entry catalog, and the 36-pair golden set are indeed what is operating in production; only the encoder was a stand-in. To add, the actual production encoder is already quantized with QAT INT4 and running. So the answer to this article's question has already been produced for our deployment, and what was measured here was whether the cheaper post-hoc quantization route produces the same value. On the latency axis, it did not.