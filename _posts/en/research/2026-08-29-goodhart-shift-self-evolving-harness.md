---
title: "An Agent That Grades Itself Every Night: Can You Trust the Report Card?"
seo_title: "The Trap of Self-Graded Agents and a Secret-Exam Check - ThakiCloud"
seo_description: "An unattended agent that rewrites its own settings overnight reports the score from a test it wrote for itself. This paper compares that score against a secret exam the agent never sees, and proposes a nightly check for whether the reported improvement is real."
excerpt: "If a student rewrote their own study notes every night, could you trust their report card? The practice score can rise while a hidden exam score stays flat or falls. This post introduces a way to catch that gap every night an unattended agent edits itself."
date: 2026-08-29
last_modified_at: 2026-08-31
tags:
  - goodharts-law
  - self-evolving-agent
  - agent-harness
  - benchmark-overfitting
  - train-holdout-divergence
  - silent-case-flip
  - overnight-automation
  - skill-routing
  - evaluation-guardrail
  - selfharness
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/research/goodhart-shift-self-evolving-harness/
canonical_url: "https://thakicloud.com/tech-blog/en/research/goodhart-shift-self-evolving-harness/"
---

If an agent that rewrites its own settings every night tells you the next morning it got better, should you believe it? The short answer is no. That grade came from a test the agent wrote for itself, not from a real exam nobody showed it.

This matters if you run unattended agents overnight or decide what to ship based on their morning report. Our research team wrote a paper, on its own, that checks an agent's claim of improvement every single night.

## In plain terms

Picture a student who rewrites their own study notes every night. They clean up what confused them and reorder how they solve problems. The next morning they say they did better than yesterday.

But the workbook this student grades themselves on every night is one they already know the answers to, a practice set they solve over and over. The teacher keeps a separate set of exam questions locked away, and the student has never seen them. A rising practice score does not guarantee the hidden exam score rises too. In the worst case the student memorizes the practice answers word for word, and does worse on the real exam because of it.

In this paper, the agent that edits itself every night is that student. The study notes it edits are the descriptions that tell the agent which tool to use for which request. The practice workbook is the set of test questions the agent always sees. The teacher's hidden exam is a set of questions set aside so the agent never sees them at all. We will call that hidden exam the secret exam for the rest of this post.

## What we did

The paper spends most of its effort on definitions and a checking method rather than new experiments. It looks at an unattended, self-editing agent loop we actually run in production.

That loop normally sees sixty-three test questions. About one in five of them, roughly fifteen, were pulled aside as the secret exam the loop never sees. The rest stayed as the practice set it checks its score against every night. The secret exam mixes questions that should trigger a tool with questions that should trigger none, because grading only one kind lets the loop go blind on the other.

The paper builds two things. One is a measurement called the secret-exam gap, the nightly difference between how much the practice score rose and how much the secret-exam score rose. The other is a six-step checker that runs this measurement automatically, every night.

## What came out

### It fetches a rising score but never proves rising ability

We saw this happen for real, in an earlier tuning pass on a different loop. The graded metric, top-pick accuracy, rose from 55.8 percent to 58.1 percent. But a metric left out of the grading, how often the agent wrongly called a tool on a request that should call none, jumped from 0 percent to 40 percent.

In plain terms, the subject on the report card went up while a subject that never made it onto the report card quietly failed. The paper calls this a case-flip, and the sharper version, where the flip happens on the secret exam during the very night the loop announces it improved, a silent flip. Looking only at the loop's own report card cannot structurally reveal a silent flip. Nights where the notes changed but neither score moved at all get their own name too, churn: compute spent, nothing to show for it.

![Two regimes of an unattended self-evolving loop: compounding improvement versus Goodhart drift](/assets/images/posts/research/goodhart-shift-self-evolving-harness/fig1_goodhart_regimes.webp)
*On the left, every edit lifts both the practice score and the secret-exam score together. On the right, only the practice score keeps climbing while the secret-exam score stalls or falls, and the gap between them builds up night after night. Both regimes look identical on the student's own report card. A conceptual illustration from the paper's analytical model, not measured data.*

### What drives the gap

So what decides the size of this gap? The paper splits every edit into two kinds. A real-understanding edit fixes something at the level of a rule, such as filling in a description so it also covers wording the agent has never seen before. This kind of edit lifts the practice score and the secret-exam score equally. A rote-copy edit just pastes the exact wording of one practice question into the notes. This kind lifts only the practice score and never touches the secret exam.

In plain terms, how many edits happened on a given night does not matter. What matters is how many of them were rote-copy edits. The paper shows this with a formula, but the point reduces to one sentence: if every edit that night was a real-understanding edit, the expected gap is zero, and the moment even one rote-copy edit slips in, a silent flip becomes possible.

![Expected contribution by edit type: transfer edits versus memorizing edits](/assets/images/posts/research/goodhart-shift-self-evolving-harness/fig2_edit_contribution_structure.webp)
*A real-understanding edit raises the practice side and the secret-exam side by the same amount, while a rote-copy edit raises only the practice side. The night's gap is set by what share of that night's edits were rote-copy edits. A conceptual illustration, not measured data.*

The paper also notes that questions left out of grading are where this gap grows fastest. If only the "should trigger a tool" questions get scored, edits drift toward serving those questions, and the "should trigger nothing" side gets fewer real-understanding edits by default. The top-pick and wrong-tool-call numbers above are exactly that pattern playing out.

### The tool that tells real from fake: the secret-exam checker

What the paper actually proposes is a six-step procedure that runs this check automatically, every night.

First, sealing. Before the first night, the secret-exam questions are set aside somewhere the loop cannot read through any path, including its own logs. Second, editing. The student edits its notes as usual overnight; the checker only watches and never steps in. Third, fixed scoring. Without changing the grading method itself, both the practice set and the secret exam get scored fresh. If the grading method changed too, no one could tell whether a rising score came from the notes or from the grader.

Fourth, a control exam. The checker also scores last night's unedited notes as if nothing had changed, which confirms the grading method does not wobble from night to night on its own. Fifth, the verdict. If the gap is small and there is no silent flip, that night's claim of improvement is approved and folded into the running report card. If the gap is large or even one silent flip shows up, that night is marked unverified and left out of the running report card. If the notes changed but neither score moved, it is logged as churn.

Sixth, handing off. A night marked unverified is not automatically rolled back by the checker. It goes to the existing rollout process instead, the one that ships changes to a slice of traffic first and pulls back if something looks wrong. The checker only answers whether it really improved, and the rollout process answers how much traffic already saw it if not.

![Full-loop train/holdout divergence gate: the night-by-night protocol](/assets/images/posts/research/goodhart-shift-self-evolving-harness/fig3_divergence_gate_protocol.webp)
*The six steps of the secret-exam checker: seal, watch the edit, score both sides on a fixed method, run a control exam, issue a verdict, and hand flagged nights to the existing rollout process. A conceptual diagram, not measured data.*

Running this checker costs almost nothing. It is one extra scoring pass on tests that already exist, with no extra model calls. Because the secret exam holds only about fifteen questions, though, one question flipping moves the whole secret-exam score by roughly 6.7 points, so no single night's result gets read on its own; several nights get read together.

## What to change

First, do not fold an unattended loop's own claim of improvement straight into the running report card. Pass it through the checker above first.

Second, never let the secret exam reach the loop through any path, not even a summary of its score. The moment it does, it stops being secret and becomes just another target for rote-copy edits. Re-seal it on a schedule with fresh questions instead, so the exam does not go stale under the loop's own eyes.

Third, keep the grading method itself frozen while the checker runs. A loop that also tunes its own grading method every night needs more than this checker alone.

Fourth, send flagged nights to the existing rollout process rather than an automatic rollback. We run exactly this kind of loop today over a tool registry of more than two thousand entries, and this week alone it rewrote eleven description files on its own. The checker is what tells us, night by night, which of those eleven edits was a real improvement. It also guards the retrieval baseline we recorded, 84 percent for landing the answer in the top five candidates and 33 percent for the top pick, against nights that churn and gain nothing.

## What not to trust

This paper is not a report of many nights of the checker actually running. It defines the check and analyzes its structure. Five things follow from that.

First, everything comes from one company and one tool list. Whether it holds for a different list elsewhere is untested.

Second, the secret exam holds only about fifteen questions. One flipped question swings the whole score, so a single night is not a reliable signal on its own; several nights need to be read together.

Third, the checker assumes the grading method stays fixed. A loop that also adjusts its own grading needs another layer on top of this one.

Fourth, the split between real-understanding edits and rote-copy edits is a simplified model built to show what drives the gap, not a description fitted to any one real loop.

Fifth, what the checker certifies is improvement within the fixed set of questions it knows about. Whether it improved on real traffic outside that set, and whether the exam itself is still a fair yardstick over time, are both outside what it can answer. The first is the rollout process's job, and the second is handled by re-sealing the exam with fresh questions on a regular cycle.

---

The full paper is here: [The Goodhart Shift](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-29-goodhart-shift-self-evolving-harness)

*Numbers in this post refer to the paper's stated setup, 63 test questions, a secret exam of roughly 15, a tool registry of about 2,234 entries, and so on, rounded for readability. Exact values stay in the figure captions. All three figures illustrate the paper's conceptual model and protocol, not measured data, and the paper itself is a methodology paper with no longitudinal measurements.*
