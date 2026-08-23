---
title: "We Auto-Tuned Retrieval Weights with a Bandit: Performance Held Steady, But Something Else Was Leaking"
seo_title: "Online Bandit Calibration for Hybrid Retrieval: A Tie and a Hidden Hallucination Cost - Thaki Cloud"
seo_description: "An experiment that calibrated the parameters of a hybrid BM25+embedding retriever routing about a thousand skills using a LinUCB bandit in real time. The result was a 192-to-192 tie, and while the bandit's preferred setting won on the tracked metrics, it also drove the hallucination rate on queries that need no retrieval at all from 0 to 0.4."
excerpt: "Can an online bandit take over from manual re-tuning of a skill router's hybrid retrieval parameters? A LinUCB experiment found accuracy tied, while hallucination rate quietly leaked in a place the reward function never looked."
date: 2026-07-27
tags:
  - contextual-bandit
  - hybrid-retrieval
  - skill-routing
  - online-calibration
  - agent-harness
  - linucb
  - reward-misspecification
  - self-evolving-systems
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/bandit-hybrid-retrieval-calibration/"
audiobook: "https://drive.google.com/file/d/1HHsCbM6FJf_TvXt6ZlLAH5gyx4E8hov_/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you run an agent harness that routes hundreds or thousands of skills or tools through retrieval, and you're tired of periodically re-tuning that retriever's hyperparameters by hand, this piece is for you. This study sought a direct answer, on a real production retriever, to the question of whether an online bandit could eliminate that re-tuning loop by auto-calibrating the retrieval parameters. The conclusion isn't a simple win or loss; it's closer to a far more practical warning.

![Illustration of the core idea of We Auto-Tuned Retrieval Weights with a Bandit: Performance Held Steady, But Something Else Was Leaking](/assets/images/bandit-hybrid-retrieval-calibration-hero.webp)
*A visual metaphor for the article's key idea.*

## The Two Numbers We Kept Re-Tuning by Hand

ThakiCloud's agent harness connects each user request to one of roughly a thousand skill definitions. The component responsible for this routing, `retrieve.py`, is a hybrid retriever: it computes a BM25 lexical score over skill names and descriptions alongside the cosine similarity of 512-dimensional EmbeddingGemma embeddings, then merges the rankings with reciprocal rank fusion. Two numbers govern this fusion: the embedding similarity threshold τ (currently 0.60) and the fusion weight w given to the lexical signal (currently 0.50).

The problem is that these two values are hand-picked by an engineer running offline benchmarks, and they get re-picked the same way every time the skill corpus changes. And the corpus really does keep changing. Skills get added, get renamed to something like `-v2` when versions bump, and get deprecated as they're absorbed into other skills. A rename immediately shakes up the lexical signal while the cached embedding lags behind unchanged, and a deprecation quietly removes one routing target. Recent research has labeled this phenomenon "library drift," a distinct failure mode of self-evolving skill ecosystems, and it's exactly this maintenance cost that this study targets head-on.

This study follows two earlier ones from the same team. The first showed that the real bottleneck in routing compound queries in this system is not query decomposition but the retriever itself, and that even a perfect decomposition tops out at a 63.6% oracle ceiling. The second built a deterministic nightly repair loop that detects retriever lexical drift and proposes fixes; that study explicitly labeled itself "a single-lever proof of concept with no bandit, no real-time reward, and no continuous online adaptation," and it still required an engineer to approve re-running the offline benchmark. This study is the next step: it directly measures whether a bandit that keeps recalibrating τ and w purely from real-time outcome feedback, with no human trigger, can beat this static default.

## Letting LinUCB Pick Retrieval Parameters in Real Time

The experiment crosses τ ∈ {0.50, 0.60, 0.70} with w ∈ {0.30, 0.50, 0.70} into a 3x3 grid of nine arms. One of these, (0.60, 0.50), is the current production default. A standard LinUCB algorithm looks at a five-dimensional context vector for every query, a bias term, query token count, the fraction of the query that is Korean, and the cumulative rename and deprecation rates observed so far, picks one arm, and runs the search through the actual production retriever code with that arm's τ and w applied directly.

This is where the study particularly earns trust. The original research question was designed to feed the bandit real-time reward signals, success/failure streaks from `skill_retro` or adversarial votes from `verify_fanout`, but the experiment actually run never wired up those signals. Instead, it replayed 63 pre-labeled benchmark cases and used a deterministic offline surrogate reward: award one point when the chosen arm's top-1 retrieval result matches the query's correct skill and passes the gate. The authors explicitly correct this gap in both the introduction and the methodology, repeatedly stating that every result in the paper is an "operationalization over benchmark replay," not a "real-time production deployment." The fact that they surface this correction rather than bury it is itself an important signal for how much confidence to place in the rest of the results.

Drift is injected on a predetermined schedule across eight rounds: two skill renames in round 2, one deprecation plus two renames in round 4, and one more deprecation in round 6, accumulating to four renames and two deprecations in total. Of the 63 benchmark cases, only the 45 positive queries that have a correct skill enter the online reward loop; the 10 native queries that should surface no skill at all and the 8 adversarially confusing negative queries are entirely excluded from the online loop and used only once, at the very end, for evaluation. Why this distinction matters becomes clear in the results below.

![Per-Round Top-1 Hits: Bandit vs Static Default vs Per-Round Oracle](/assets/images/posts/research/bandit-hybrid-retrieval-calibration/fig-rounds-hits.webp)
*A chart comparing top-1 hit counts for the bandit, the static default, and the per-round oracle across eight rounds. Measured on a local bench harness.*

## 352 Observations, Exactly 192 to 192

Summed across all eight rounds and 352 positive-query observations, the bandit and the static default each recorded exactly 192 top-1 hits. The pre-registered outcome variable, "the bandit beats the static default," was confirmed false. Of the nine arms, the best fixed arm in hindsight was (τ=0.50, w=0.50), with 208 hits, meaning both policies carried exactly 16 hits (7.7%) of cumulative regret against the per-round oracle.

More striking is that this figure of 16 wasn't a bandit-specific flaw. The static default also hit exactly 24 per round, and the oracle exactly 26 per round. What looks like a slowly rising hit rate across rounds isn't due to improving retrieval quality; it's because queries whose correct answer was a deprecated skill drop out of the pool, shrinking the denominator (query pool size) from 45 to 43. In other words, the drift schedule injected in this run never once moved the actual hit counts of the static default or the oracle. The authors themselves call this a "manipulation check failure" and draw an honest line: this experiment alone can neither confirm nor refute drift adaptability.

Round by round, the bandit does learn something. In round 1 it trails the static default 24 to 22 during exploration, ties in round 2, and pulls ahead once each in rounds 3, 4, and 6. But that learning never converges. Its preferred-arm share for (0.5, 0.7) climbs monotonically from 51.1% to 88.6% through round 4, then suddenly collapses to (0.6, 0.3) in round 5, when no new drift was injected at all, and it gets overtaken 23 to 24. It settles on (0.5, 0.3) in round 6 and returns to (0.5, 0.7) in rounds 7 and 8, but never recovers its round-4 peak. The authors attribute this oscillation not to drift but to exploration noise from LinUCB's α held fixed at 1.0 with no decay, in a setting where each round has only 43 to 45 queries and a single hit swings the result by about 2.2 percentage points.

![Cumulative Regret of LinUCB Bandit Against Per-Round Oracle](/assets/images/posts/research/bandit-hybrid-retrieval-calibration/fig-regret-trajectory.webp)
*Shows cumulative regret against the oracle building up to 16 hits (7.7% relative) over eight rounds, driven by early exploration and mid-run oscillation. Measured on a local bench harness.*

## What Was Leaking Beneath the Surface: A Safety Cost the Reward Never Saw

The most important table in this paper evaluates three fixed configurations, once each, against the full positive, native, and negative query sets, at the final drift state. Looking only at the two metrics the reward function could actually see, positive-query top-1 hit rate and gated top-5 recall, the arm the bandit ended up selecting most often, (τ=0.50, w=0.70), clearly beats the static default. Top-1 hit rate rose from 0.558 to 0.581, and recall rose from 0.814 to 0.860.

But looking at the other two metrics together flips the picture. That same arm drives the hallucination rate on native queries, which should surface no skill at all, from 0.0 to 0.4. Four out of ten queries that should have returned nothing now force out a skill anyway. What's more, the failure rate for incorrectly passing an adversarially confusing negative query was identical at exactly 0.375 across all three configurations, revealing that this axis simply isn't something τ and w tuning can touch at all.

Pinning down the cause more precisely, this hallucination cost isn't a problem of the bandit's learning process itself; it traces directly to the τ value. Even the best fixed arm in hindsight uses τ=0.50, so it produces the exact same 0.4 hallucination rate as the bandit's preferred arm. The only configuration in the table using τ=0.60, the current static default, is also the only one with a hallucination rate of zero. In other words, any procedure that maximizes a reward function that only looks at positive queries, whether that's a bandit, an offline grid search, or even a human reading only the positive metrics, converges to a low τ and inherits the same cost. A human running the full offline benchmark can see the hallucination-rate column and reject that trade; an online loop that only sees the positive metrics never has that option to begin with.

![Final Three-Way Comparison: Positive Metrics vs Hallucination Rate](/assets/images/posts/research/bandit-hybrid-retrieval-calibration/fig-threeway-comparison.webp)
*The bandit's final preferred arm (τ=0.50, w=0.70) beats the static default on the rewarded metrics but drives native-query hallucination rate from 0.0 to 0.4. Measured on a local bench harness.*

## What This Experiment Means for the Company and the Field

For ThakiCloud, the conclusion is clear. The attempt to hand `retrieve.py`'s hybrid parameters over to an online bandit and eliminate the human offline re-tuning loop lacks sufficient grounding in this form. Offline benchmarking is cheap to run, and it's currently the only point in the system that measures native-query hallucination and negative-query false positives. Replacing it with an online loop that only sees positive metrics trades a complete but periodic evaluation for a continuous but partial one.

More broadly, this result has something to say to agent systems in general that use retrieval-augmented generation or tool routing. Continuously auto-calibrating retrieval hyperparameters from real usage feedback alone is an attractive way to reduce engineering maintenance burden, but when the reward signal's scope is narrow, performance can appear to improve on the surface while a safety cost quietly builds up on an axis that signal never sees at all. This study shows that risk not as an abstract warning but as real numbers.

Academically, prior work has applied bandits to calibrating hybrid lexical-embedding fusion weights, but most of it ran on synthetic rewards or reimplemented retrievers. This study took the actual production retriever code as-is and measured it under conditions where renames and deprecations were programmatically injected. It stands out as a rare case both for reporting a null result and for diagnosing the concrete mechanism behind that null result, reward misspecification.

## Limitations: How Far Can We Trust This Result

The limitations the authors disclose themselves matter for interpreting the result. First, because the reward was a benchmark-derived surrogate rather than the real-time signal originally pre-registered, this paper doesn't tell us what would happen if a genuine real-time signal like `skill_retro` or `verify_fanout` were used as the reward instead. Second, the static default used as the comparison baseline isn't a naive default; it was tuned offline on the same benchmark family this online experiment replays, making it a strong baseline that has effectively already seen the test set. That a bandit starting from a cold start caught up to that opponent to a tie is hard to dismiss, but it also can't be stretched into a general conclusion that "online adaptation is unnecessary."

It's also an important constraint that the injected drift never moved the aggregate hit rates of either the static default or the oracle at all. This experiment ultimately failed to measure drift adaptability, so any conclusion about drift-adaptation methodology remains untested rather than validated. The benchmark is also small, 63 cases and 352 observations, so it's quite possible there simply wasn't enough information for a five-dimensional-context, nine-arm LinUCB to statistically distinguish the arms in the first place. The experiment was also run only once, with a single fixed α and a single drift schedule, so no variance or confidence interval can be computed, and we can't rule out that the tie observed here was a matter of good or bad luck.

The authors' proposed next steps are clear: widen the reward scope to include native and negative queries, add a constraint that guarantees no regression below the static default, design a drift schedule strong enough to actually move the static default before testing a drift-adaptive bandit, and finally, wire up the real-time signals like `skill_retro` and `verify_fanout` that were originally planned. Until then, this paper's conclusion is that a human-triggered offline benchmark loop must remain the safety net, or at minimum an indispensable complement to online calibration.

The full paper page is available [on Hugging Face](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-27-bandit-hybrid-retrieval-calibration).
