---
title: "We Searched All of Korea's Statutes for Numeric Contradictions: Zero Confirmed, and the Gaps Were in Amendment Lag"
seo_title: "A Census of Numeric-Threshold Conflicts in Korean Statutes with a Code Oracle and Three-Model Consensus - ThakiCloud"
seo_description: "For engineers who want to check numeric consistency across regulations and contracts automatically. We checked 8,055 age, amount, period, and ratio comparisons across Korea's public statutes with a code oracle and a Claude, GPT, and Qwen consensus. Zero conflicts were confirmed; the real mismatches came from amendment lag, where a law changed and its enforcement decree had not caught up."
excerpt: "Among clause pairs linked by explicit citation, three model families never unanimously confirmed a case where the current texts contradict each other on a numeric threshold. Real mismatches showed up in the gap between amending a law and amending its decree."
date: 2026-09-26
last_modified_at: 2026-09-26
tags:
  - korean-legal-nlp
  - statute-audit
  - code-oracle
  - multi-model-consensus
  - amendment-lag
  - document-consistency
  - on-prem-llm
  - research
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/statute-numeric-conflict-audit/"
---

This post is for engineers and legal or compliance teams who want to check automatically whether the deadline in one clause agrees with the deadline in another, across internal rules, terms of service, or a stack of contracts. We ran that check against the most carefully maintained document set we could find: every public statute in Korea. The result fits in two sentences. Among clauses that explicitly cite each other, three model families never all agreed that the current texts contradict each other on a numeric threshold. The mismatches that did exist came from **amendment lag**, where a law changed first and its enforcement decree had not yet caught up.

## What we checked

We looked at numeric thresholds that can be turned into intervals: ages, amounts, periods, and ratios. "Age 65 or older" becomes [65, ∞) and "within 30 days" becomes (−∞, 30]. Once both sides are intervals, whether two clauses conflict is an interval comparison, not a question for a model. If a law sets "within 30 days" and the decree it delegates to says "within 60 days", the lower rule has left the range of the higher one, and code catches that deterministically.

Code also decides which clauses get paired. We used four relations: a decree citing "Article N of the Act" (delegation), one article of a law building on another with "pursuant to Article N" (same-law references), a higher number that changed in the amendment history while the lower clause stayed put, and administrative-fine schedules whose amounts exceed the statutory cap. Citations where the legislature deliberately carved out an exception, such as "notwithstanding" or proviso clauses, were excluded.

![A seven-stage flow: public statutes, number extraction in code, pairing by explicit citation, an interval oracle in code, Qwen3.8-27B ranking, blind review by Claude, GPT and Qwen, and confirmation only on unanimity](/assets/images/statute-numeric-conflict-audit-fig2-en.webp)
*Models only order the candidates. Whether a pair conflicts is decided by the interval oracle and agreement across three model families.*

The models had two jobs. Our in-house Qwen3.8-27B judged whether two numbers really describe the same quantity and ordered the review queue. Then Claude, GPT, and Qwen each reviewed every pair without seeing the others' answers. A conflict was confirmed only when all three said so and the evidence each quoted appeared verbatim in the source text. There was no human review. Code decides agreement across the three families and checks the quoted evidence.

## First, can the checker catch a real conflict?

Zero is only meaningful if the checker can find real conflicts, so we planted some. We took consistent clause pairs and had GPT change one number in the lower clause so it fell outside the higher clause's range, under a protocol that never looked at the checker's code. On a fresh sample of 65 pairs, with every pair used in development excluded, the checker caught all 65 (Wilson 95% lower bound 94.4%).

It did not start there. The first version reached a lower bound of only 84.8% and failed the 90% bar. It missed upper limits phrased as negations ("shall not exceed"), definitional sentences ("N means ..."), and eligibility-style delegations where the higher rule fixes a value and the lower rule only narrows who qualifies. We fixed those three, sealed the rules again, and only then passed.

## How 1,201 pairs became zero

![A log-scale bar chart: 8,055 numeric comparisons, 1,201 pairs the oracle judged out of range, 2 pairs both Claude and GPT called conflicts, and 0 with three-family unanimity](/assets/images/statute-numeric-conflict-audit-fig1-en.webp)
*By the numbers alone, 1,201 pairs look inconsistent. Pairs where both numbers describe the same quantity for the same subject are rare.*

Of 8,055 numeric comparisons, the interval oracle judged 1,201 unique pairs to have the lower clause outside the higher clause's range. On numbers alone, that is more than 1,200 candidate contradictions.

The reviewing models mostly saw something else. In 478 pairs the two numbers were never the same quantity: two different deadlines from the same article, or a fine cap matched against a charging basis. In 378 pairs the subjects differed, and in 247 the difference was deliberate, such as a stricter standard for one group or a special rule sitting next to a general one. On the fine-schedule side, all three models agreed that none of the 14 pairs the oracle flagged was a conflict, and the ones we opened turned out to be PDF table-extraction noise.

The lesson here is about method more than about the law. A checker that compares numbers is good for casting a wide net, but it cannot be the verdict. It has to be followed by a step that decides whether both numbers describe the same quantity for the same subject.

## The real gap: a law changes, the decree stays

Real mismatches came from amendment history. We built a separate detector that looks for a higher-law number changed by amendment while the lower clause that relies on it carries an older amendment mark. To see whether it would have worked in the past, we rolled the statute history back to January 1 of 2020, 2023, and 2024 and ran the same check.

From the January 1, 2023 snapshot, one pair was later actually fixed. Article 12(2)(b) of the Income Tax Act sets which high-value homes are excluded from the rental-income tax exemption for single-home owners. An amendment on December 31, 2022, effective January 1, 2023, raised that threshold from a standard price above KRW 900 million to above KRW 1.2 billion. At that point, Article 8-2(5) of the Enforcement Decree still referred to "houses whose standard price exceeds KRW 900 million". The detector flagged the mismatch at that past date, and a later amendment resolved it. This is the only resolved pair across the three snapshots, so it says nothing about the detector's precision. It does show once that "not yet resolved" does not automatically mean "false positive".

The strongest current candidate is in the Act on Support for Persons Eligible for Veteran's Compensation. Article 51(6), amended and in force from September 8, 2026, widened the group eligible for reduced fees at contracted medical institutions from age 75 and older to age 65 and older. Article 63(2) of the Enforcement Decree, which sets the reduction rate, still names "75 or older" in its 2021 wording. Claude and GPT both judged this a mismatch that exceeds the delegation. Qwen, even when asked again, called the clause obsolete rather than conflicting. Under our rules that is not unanimity, so the pair stays on a watch list rather than being confirmed. A decree amendment may already be underway, so we present it as an amendment-lag candidate, not a contradiction. Three more pairs whose amended laws have not yet taken effect, in the Credit Unions Act, the Foreign Exchange Transactions Act, and the Act on Improving Training Conditions for Medical Residents, will be rechecked after their effective dates.

## Can a 4B model do the job?

We also ran the same 1,201 pairs through K-Decision, ThakiCloud's 4B judgment model. One H100 finished all 1,201 in 53 seconds. On "do these two numbers describe the same quantity?", it agreed with the Claude and GPT consensus 98.7% of the time. On "do these two clauses conflict?", it called 962 pairs conflicts and agreed only 19.6% of the time, which is a bias toward giving nearly every pair the same answer. A small model works as a cheap, fast first filter, but the conflict verdict belongs to code and large-model consensus.

## How to read this result

Zero confirmed does not mean Korean statutes have no numeric contradictions. This check only covered clause pairs linked by explicit citation. Two laws covering the same subject without citing each other, complex tables inside schedules, case law, and administrative rules were all out of scope. Requiring unanimity across three families was also deliberately conservative. Claude and GPT both flagged two pairs as conflicts, and the veterans' case is one of them. A rule like "two or more agree, plus a check against the source" could change the outcome, but that change has to come as a new sealed rule, not as a re-judgment of one pair after seeing the results.

## What this means for ThakiCloud products

The part worth keeping is the structure, more than the list of statutes. Models cast a wide net, deterministic code makes the call, and a result counts only when models from different families agree with quoted evidence. That structure transfers directly to documents other than statutes. A bank's product terms and internal rules, a public agency's guidelines and bylaws, or a company's stack of contracts are amended with far less review than legislation, which leaves more room for mismatches.

In **Paxis**, this becomes a "rule consistency audit" workflow: whenever a document is amended, find the affected clauses, judge them with the oracle, and send only the pairs where the models disagree to a reviewer for approval. **Metis** serves the 27B ranking model and the 4B filter. For finance and public-sector customers whose rule documents cannot leave their network, the same pipeline runs on-premises on **Aegis**. Where external models are not allowed, the consensus step switches to in-house models from different families.

All figures here are measurements on a public statute snapshot (legalize-kr) as of September 23, 2026, and they are machine-consensus results that no person reviewed.
