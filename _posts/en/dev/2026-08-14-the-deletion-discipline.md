---
title: "Why Deleting Code Always Gets Postponed"
excerpt: "Deleting unused features is not a technical problem. It is a problem of missing evidence tiers and missing sequencing. This piece lays out how a team can replace endless deprecation arguments with a fixed grading system and an order of operations, then turn deletion into a standing habit instead of a one-time cleanup."
seo_title: "Why Teams Can't Delete Old Code, and an Evidence-Based Way to Fix It"
seo_description: "A practical framework for deprecating software safely: evidence tiers for proving something is unused, a five-step teardown order, and how to make deletion a recurring engineering habit instead of a rare cleanup project."
date: 2026-08-14
last_modified_at: 2026-08-14
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - tech-debt
  - code-deletion
  - software-engineering
  - deprecation
  - engineering-culture
  - legacy-systems
  - api-versioning
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-deletion-discipline/"
ebook: /assets/ebooks/the-deletion-discipline.pdf
ebook_title: "The Deletion Discipline"
ebook_pages: 33
audiobook: "https://drive.google.com/file/d/1fpLggpWpSBigJmrPDLfyB611lLaNHjV1/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

Every engineering org has a well-worn path for shipping something new: a design doc, a review, tests, a deploy pipeline. New hires learn it in week one. Almost no org has an equally well-worn path for removing something old. This piece is for engineers and team leads who have watched a codebase grow in only one direction for years and want to know why. The short answer is that deletion fails not for lack of ability but for lack of a decision procedure, and the fix is to replace judgment calls with a fixed evidence grade and a fixed order of operations.

Here is the argument in full before the details: teams do not fail to delete code because the code is hard to remove. They fail because nobody has agreed on what counts as proof that something is safe to remove, and nobody has agreed on what order to remove things in. Fix the evidence question with a small graded scale, fix the ordering question by always deferring the irreversible steps to the end, and deprecation stops being a debate and becomes a checklist. Boring is the goal.

![Illustration of the core idea of Why Deleting Code Always Gets Postponed](/assets/images/the-deletion-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## The Monthly Bill a Live Code Path Never Stops Sending

"It's just sitting there, what does it cost?" is a question every engineer has heard, and it sounds reasonable at first. Disk is cheap. Compute is usually not the bottleneck. But the bill for a dead code path is never denominated in infrastructure spend. It is denominated in people's time, and it renews automatically every month the code stays alive.

A single live code path charges five separate costs. There is a reading cost: anyone touching a neighboring function first has to figure out what this path does and whether it is safe to leave alone. There is a testing cost: CI exercises this path on every run, and that time multiplies across every engineer waiting on the pipeline. There is an incident-surface cost: any path touching auth, permissions, or an external call gets re-audited every time a new vulnerability advisory lands, whether anyone uses it or not. There is a migration tax: when the team upgrades a framework or moves databases, dead functionality gets ported along with everything else, and this tax is consistently the most expensive of the five. And there is a cognitive-load cost: a new hire asks "why does this exist" and nobody can answer with confidence, which quietly erodes trust in the whole system.

The first four costs are measurable: pipeline minutes, review time, and incident-response hours all show up as numbers somewhere. The fifth is harder to quantify, but it shows up reliably in exit interviews as a reason people give for leaving. What matters most is that none of these costs are a one-time charge. Building a feature is a single payment. Keeping it alive, used or not, is a subscription, and every sprint a team defers deletion, it is quietly renewing that subscription without ever having decided to.

## "Nobody Uses This" Is Not Evidence

The most common way deprecation work fails is not that a team deletes the wrong thing. It is that the team never gets past arguing about it. "I don't think anyone uses this" meets "let's keep it just in case" in meeting after meeting, and neither side has evidence, so neither side can be wrong, and the conversation never converges. An argument built on two hunches can only end in another hunch.

The fix is not a more persuasive case for deletion. It is a graded scale for evidence, agreed on in advance, where every grade has a fixed set of actions attached to it. Once the grade is defined, the meeting stops being about whether to delete and starts being about which grade the evidence currently sits at. That question has a factual answer, so the meeting gets shorter every time you have it.

A four-tier scale works well in practice.

| Tier | Evidence | Permitted action |
|---|---|---|
| E0 | Gut feeling only | Add instrumentation |
| E1 | No static references | Isolate and announce |
| E2 | No runtime calls observed | Trial cutoff |
| E3 | Every caller identified | Remove |

E0 is the default state: no evidence at all. The only thing permitted at E0 is attaching instrumentation, because that single rule quietly eliminates a large share of deprecation incidents by ruling out deleting anything on a hunch.

E1 means a static sweep, meaning the source tree, the routing table, and the build artifacts, turns up no reference to the path anywhere. That is strong evidence, but it is only half the picture. Reflection-based calls, paths assembled from strings at runtime, class names buried in a config file, and endpoints hit directly by an external caller are all invisible to static analysis, so E1 alone is never enough to justify removal.

E2 adds a runtime observation window: the path was called zero times over some defined period in production. E1 and E2 together are usually sufficient to move an internal-only feature into the teardown sequence. E3 is the tier required when calls are still happening. It means every remaining caller has been identified by name, and each one has either migrated or has an explicit agreement about when it will. Anything you expose as a public API needs to reach E3 before you touch it, no exceptions.

Evidence comes from three distinct layers: static analysis, runtime observation, and a human who actually knows the system. Relying on only one layer is a reliable way to be wrong. Trust static analysis alone and you miss anything invoked through reflection. Trust runtime logs alone and you will misclassify a rarely called batch job or a fiscal-year-end reporting path as dead code, simply because it did not happen to fire during your observation window.

Consider a concrete case: an internal reporting feature that has logged zero calls for three months. Static analysis and runtime logs together look like a clean E2. It seems safe to remove right now. But if that feature only runs during fiscal year-end close for the finance team, three months of logs will never catch it. That is exactly what the third layer, a conversation with someone who actually built or owns the feature, is for. Skip that layer and you will keep deleting seasonal functionality on the strength of a quiet log window, and the incident will repeat.

## Getting the Order Wrong Turns a Correct Call Into an Outage

Reaching E3 evidence does not mean you should delete immediately. Most deprecation incidents are not caused by a wrong judgment call about whether something is unused. They are caused by doing the right steps in the wrong order. Delete code before cleaning up the data it wrote, and you reach an irreversible state before you needed to. Cut off a feature without warning anyone, and a technically flawless piece of engineering becomes a trust incident with your users.

A safe teardown moves through five stages in a fixed sequence, and each stage has a condition for advancing rather than a date. In the observe stage, you attach instrumentation until the evidence reaches E2. In the announce stage, you communicate a sunset date and work through objections before moving on. In the friction stage, you add warnings or artificial delay to the remaining calls and confirm that usage is actually dropping in response. In the cutoff stage, you turn the feature off and watch for a defined quiet period with no incidents. Only then does the remove stage happen: code and resources are deleted, and you wait out a recovery window before considering the work done.

The thing that matters at every stage is the condition for moving forward, not the calendar date. A stage with a deadline but no exit condition eventually gets skipped under deadline pressure, because the date arrives whether or not the condition was met. And the rollback plan needs to be written during the observe stage, not improvised later. Which commit to revert, which flag re-enables the old path, where the data backup lives: writing this down in a panic during an actual incident is much harder than writing it down calmly on day one.

Never skip the announcement. A good sunset notice needs exactly four things: what is going away and when, what to use instead, who to contact with a problem, and what happens if the recipient does nothing at all. How long the notice window should be depends entirely on the audience. Two to four weeks is reasonable for a feature only one internal team touches. A full quarter makes sense for a tool used company-wide. An externally facing API deserves at least two quarters, longer if a contract says otherwise, and the contract terms always win. It is also worth remembering that a notice buried in a wiki page is a notice nobody reads. Reach people through the channel they actually use the feature from.

## Code Is Reversible. Data and Contracts Are Not.

Code is reversible in the truest sense: revert the commit, redeploy, and you are back to the previous state within minutes. Data is not like that. Drop a table and the only way back is a backup restore, which is measured in hours, not minutes. An external contract is heavier still, because reversing it depends not on your own deploy cadence but on the other company's schedule. This is exactly why the teardown sequence above places data and contracts at the very end.

Public APIs, webhooks, event topics, and shared views cannot be judged by searching your own codebase, no matter how thoroughly. You have to identify the callers first, and the identification signals rank by accuracy. Auth credentials, meaning call volume broken down by token, key, or client ID, are the most precise signal available. User-agent strings and client version headers are next, imprecise but useful for guessing what kind of software is calling. Source IP ranges help distinguish an internal caller from a specific partner. And contracts and billing records sometimes hold users that never show up in any technical metric at all.

If calls remain that cannot be identified through any of these signals, that gap is itself a defect worth fixing on its own, independent of the current deprecation effort. Attaching minimal identification to any endpoint that is open without authentication pays off the next time you have to do this. Once you have a caller list, sort it into three buckets: migrated, migrating, and unreachable. The last bucket is the one that matters most. For callers you cannot reach by any other means, the friction stage described above, tightening rate limits and adding latency, is effectively your only remaining communication channel, and in practice it works: teams that throttle an unreachable caller often hear from its owner within days.

If the API is versioned, the process is simple: ship a new version, put a sunset date on the old one, and turn it off on that date. The harder reality is that most internal APIs were never versioned in the first place. Even without a version, you can approximate the same effect: add a sunset header to responses, and track in your logs which clients keep calling after receiving it. That gives you a version-free way to measure the same signal a real version bump would give you.

## Making Deletion a Habit Beats Winning a Big Cleanup Once

Follow every step above and a single feature disappears cleanly. But next quarter twelve new features ship, and a few of them will end up just as unused. A single cleanup project cannot win a race that resets every quarter. The unit of measurement has to shift from individual deprecations to a deprecation rate. If the rate you build at is faster than the rate you clean up at, debt grows without bound no matter how well any single cleanup went. The actual goal is keeping the two rates close to each other.

The highest-leverage habit is attaching an exit condition to everything new, at the moment it is created, rather than deciding later. Experimental feature flags should carry a mandatory expiration date, and the pipeline should warn or fail once that date passes. Temporary workaround code should have its removal condition tracked as an issue, not a comment, because comments are never searched but issues stay visible in a backlog. New APIs should be versioned from day one, because a contract that starts unversioned has no clean way to end. Pilots and trial rollouts should carry both a sunset date and an explicit written statement of what happens if the success criteria are not met.

The point is not a promise to decide later, but a structure where things disappear automatically if nobody intervenes, because cleanup depending on someone's future willpower always loses to whatever is more urgent that week. Open feature flag count is a particularly visible leading indicator here: a rising count usually means the experiment behind each flag already ended, and the flag is the only thing still forcing two branches of behavior nobody needs.

Do not try to make deprecation work win a prioritization fight against new features in a planning meeting. It is better not to let the two compete at all. In practice, teams handle this by reserving a fixed share of sprint capacity for deprecation work, or by setting two or three deprecation targets each quarter and managing them with the same seriousness as any feature goal. The exact percentage varies by team, but the principle of carving out a dedicated budget is what actually breaks the pattern of cleanup always losing to the next feature.

That budget only survives if it shows up as a real metric: lines of code removed, flags closed, internal APIs sunset this quarter, tracked on the same dashboard as feature-launch numbers. Deletion done in silence looks like nothing happened. Deletion tracked as a number looks like progress, and progress survives the next planning cycle.

The reason deletion is hard is not the code itself. It is the absence of an agreed evidence bar and an agreed order of operations. Fix the evidence question with a small graded scale, and arguments get shorter. Fix the ordering question by deferring anything irreversible to the very end, and a correct judgment call stops turning into an outage. Build exit conditions into everything from the day it is created, and the next big cleanup stops being necessary at all.

## References

- The sunset header you attach to an unversioned API is a defined IETF standard. RFC 8594, "The Sunset HTTP Header Field". [https://www.rfc-editor.org/rfc/rfc8594](https://www.rfc-editor.org/rfc/rfc8594)
- The origin of treating open feature flags as inventory with a carrying cost, and putting expiration dates on them. Martin Fowler, "Feature Toggles (aka Feature Flags)". [https://martinfowler.com/articles/feature-toggles.html](https://martinfowler.com/articles/feature-toggles.html)
