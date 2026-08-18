---
title: "Your Time Bug Is Actually a Type Error"
excerpt: "A settlement off by a day, a batch job that ran twice, timeouts firing in a storm for no visible reason: these look like unrelated incidents. They are not. Every one of them traces back to the same mistake: cramming three different concepts, an instant, a wall-clock reading, and a duration, into a single type."
seo_title: "Why Time Bugs Fail Silently: One Root Cause From Timezones to Schedulers"
seo_description: "Settlement discrepancies, duplicate batch runs, timeout storms. The recurring failure in systems that handle time traces to one design mistake: collapsing distinct time concepts into a single type. Here is the discipline that fixes it."
date: 2026-08-19
last_modified_at: 2026-08-19
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - time-handling
  - timezone-bugs
  - distributed-systems
  - scheduling
  - bitemporal-data
  - clock-synchronization
  - backend-engineering
  - system-design
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/engineering-with-time/"
ebook: /assets/ebooks/engineering-with-time.pdf
ebook_title: "Engineering With Time"
ebook_pages: 33
---

If you have maintained code that touches time for more than a couple of years, this will sound familiar. A settlement figure comes out a day off. A nightly batch job runs twice before dawn. Timeouts that had been quiet for months suddenly fire in a wave. These look like separate incidents with separate root causes, and most postmortems treat them that way. This piece argues something narrower: they are the same bug wearing different clothes, and the bug is not a logic error. It is a type error your language never caught.

We treat time as one concept: a single database column, a single date object, a single string field in an API payload. But physical time is at least three distinct things, and those three obey different arithmetic. An instant can be subtracted from another instant to get a duration. A wall-clock reading cannot be handled the same way, because it depends on a location the raw value does not carry. Pour distinct things into one container and a wrong operation will eventually pass code review, since nothing in the type signature says it is wrong. What follows walks through four places that exact mistake shows up, not as a table of contents, but as four independent proofs of one claim.

![Illustration of the core idea of Your Time Bug Is Actually a Type Error](/assets/images/engineering-with-time-hero.webp)
*A visual metaphor for the article's key idea.*

## Why These Bugs Stay Quiet For Months

Time bugs are unusually hard to catch because they do not announce themselves. A null pointer throws immediately and leaves a stack trace pointing at the exact line. A time bug does not: the code executes the calculation it was told, the logs show no exception, and the test suite is green. The discrepancy surfaces months later, when someone reconciling a settlement report by hand notices a number does not add up.

Trace enough of these incidents back and a pattern emerges. The code was not wrong; the operation it was asked to perform simply did not correspond to anything physically coherent. Adding thirty minutes to two thirty in the morning is well-defined almost every day, except the day daylight saving begins, when that wall-clock moment might not exist. Most languages accept the arithmetic anyway and hand back a number, since nothing in the type says the operation was nonsensical.

The reason compilers miss this is structural. In most languages, time is one type, treated the way an integer or a string is: a generic value with no encoded distinction between an instant, a wall-clock reading, or a duration. A mistake the type system cannot see has to be caught by a human remembering the distinction on every line, and human memory reliably fails at that scale.

That is why checklists do not solve this. A checklist assumes a human will notice the mistake, and time bugs are the mistakes humans are worst at noticing, because the code looks ordinary. The only fix that holds is making distinct things distinct types, so the wrong operation cannot be expressed at all, rather than flagged after the fact.

## Three Different Grammars: Instant, Wall Clock, Duration

Once laid out, the taxonomy is simpler than it sounds. The first is the instant: a single point observable identically from anywhere in the universe, usually represented as seconds since a fixed epoch. The moment a payment is authorized and the moment a log line is written both live here. Instants can be subtracted from each other, and the result is an elapsed length of time.

The second is the wall-clock reading: what a calendar and a clock face display, a specific year, month, day, hour, minute, second. On its own this is not an instant. Without knowing whose clock face it came from, you cannot pin down a point on Earth, and in some regions certain readings do not correspond to any real moment. Alarms, meetings, deadlines, and shift schedules live here, and cannot be treated as instants without anchoring them to a place first.

The third is duration, and it splits again. Some durations have a fixed physical length, like ninety minutes. Others depend on a calendar and change length, like a month or a day crossing a daylight-saving boundary. Fixed durations add directly to instants. Calendar-dependent durations only add to wall-clock readings, and converting the result back to an instant means running the local rules again.

| Property | Instant | Wall-clock reading | Fixed duration |
|---|---|---|---|
| Reference point | None, globally single | A specific region's calendar | None |
| Can the value fail to exist | No | Yes, e.g. the hour skipped at DST start | No |
| Needs a regional rule | No | Yes | No |
| Subtractable from its own kind | Yes, result is a duration | Only within the same region | Yes |

The point is not the individual cells but that all four rows differ across the three columns, which is exactly why collapsing them into one type is unsafe. Apply instant-shaped arithmetic to a wall-clock reading and you can construct a value that never existed. Apply wall-clock-shaped arithmetic to an instant and you drag in regional rules it never needed.

## Storing an Offset Outsources a Political Decision to the Future

Timezone bugs are the most common shape this violation takes. Many engineers store a time zone as an offset, plus nine hours, because it is convenient to read. The offset is only a valid answer for one specific instant, not a value stable enough to persist. A time zone is the name of a region, and behind that name sits a rule set describing how the offset has changed and how it is scheduled to change.

This becomes dangerous with the future. Governments change standard time and daylight-saving schedules by political decision, sometimes with only weeks between announcement and effective date. A reservation stored with a region identifier automatically points at the correct instant once the rule updates. One stored as a raw offset stays locked to the old rule. The moment a government changes its mind, every offset-based reservation silently drifts by an hour, with nothing flagging it.

The same trap exists historically. The offset a country uses today was not always the offset it used; standard time has shifted before, and daylight saving has been adopted and abandoned at different points. Hardcode an offset while processing old records and the periods where it did not apply quietly come out wrong. A statistics chart with one year that looks off for no obvious reason is, more often than expected, exactly this class of bug.

The working rule is short: what you persist is a region identifier, and the offset is a derived value computed from that identifier plus a specific instant, never the other way around. Showing the offset to a user is fine. Read it back in as input to a future calculation, though, and you are asking today's code to predict a political decision no one has made yet, and no system has ever succeeded at that.

## Two Clocks Sharing One Name

If timezones are a problem humans create, this one is a problem machines create. Operating systems generally expose two distinct clocks. One, the system clock, tells you what time it is right now; it is human-readable and fine for records, but can be adjusted forward or backward whenever an external time-sync service corrects it. The other, the monotonic clock, tells you only how much time has elapsed since a fixed reference point. It never runs backward, but it cannot tell you what time it is.

The uses split cleanly. Measuring elapsed time between two points, a timeout, a latency check, a retry interval, requires the monotonic clock. Recording when something happened, a log entry, an audit trail, requires the system clock. The trouble is that the default time function most languages expose does not tell you, from its name alone, which one you are getting.

Ignore the distinction and symptoms show up loudly. The instant a time-sync correction nudges the system clock back a second, every timeout measured against it either waits an extra second or expires immediately. It gets worse when a server's clock has drifted significantly and gets corrected all at once: connections can expire simultaneously, or connections that should have expired minutes ago stay alive. The incident report says connections spiked suddenly, and the real cause surfaces weeks later.

Distributed systems add one more layer of the same illusion. Code that compares timestamps from two different servers to decide which event happened first implicitly assumes the clocks agree perfectly, an assumption no distributed system satisfies. Clocks on different machines run at slightly different rates, and synchronization protocols reduce the error without eliminating it. Where ordering genuinely matters, you need a mechanism that guarantees order directly rather than inferring it from timestamps, once again the same mistake: making one value carry both when something happened and in what order.

## A Scheduler Is Asking What, Not When

Recurring batch jobs are another face of the same confusion. A job runs at the top of every hour. What does it actually do? Almost always, it processes whatever accumulated in the past sixty minutes. If that is true, the essence of the job is not waking up on the hour, it is consuming a specific span of time. The clock striking the hour is only the trigger; it is not the job itself.

That reframing changes the design. Pass the job's argument as the start and end of the span it should process, not the moment it happened to run, and reprocessing yesterday's three o'clock span becomes a matter of calling the same code with different arguments. Code that depends on the execution timestamp cannot do that, which is how a separate backfill script gets written. That script drifts from the main path and eventually produces a different answer for the same data. One correct answer has quietly become two.

Treating the span explicitly also exposes gaps for free. Record which spans have already been processed and finding an empty one is a single query away, so a stalled scheduler becomes something monitoring catches, not something a customer reports first. The boundary convention matters too: the start of a span is included, the end excluded. Break that convention and two adjacent spans will either double-count one instant or drop it, and in a settlement pipeline that single inconsistency fails a reconciliation.

Duplicate execution falls out of the same frame. A distributed scheduler will eventually launch the same job twice, when leader election wobbles, when a deployment briefly overlaps two instances, when a partition convinces both halves the other side is dead. Guaranteeing exactly-once execution is expensive and still not airtight. But design the job around processing a span, and running it twice stops mattering, since reprocessing the same span and producing the same result is safe no matter how many times you repeat it. Chasing a perfect guarantee is the expensive path; designing the operation to be harmless when repeated buys the same stability more cheaply.

## Valid Time and Recorded Time Are Two Different Axes

Systems that handle time eventually get the same request: recompute last month's settlement, calculate a customer's rate as it stood back then, backfill six months of history because a metric's definition changed. Whether a system can handle that request is a reasonable measure of its maturity, and the answer again comes from splitting time into two.

One axis is when a fact became true: the day a contract took effect, the day a rate plan started, the day an employee changed departments. The other is when the system learned it: the moment a staff member entered it, the moment an external system delivered it. That these two can differ is the entire point. A department transfer effective March first getting entered on March fifteenth is completely ordinary, not an edge case.

Record only the moment of entry and you cannot reconstruct what the org chart looked like on March tenth. Record only the effective date and you cannot reconstruct what the system actually knew on March tenth. Audit responses and dispute resolution almost always need the second answer, because the question is whether a decision was reasonable given the information available when it was made, not information that arrived later. Without both axes, there is no way to even ask that question.

The implementation is simpler than it sounds. In any table where history matters, replace in-place updates with appended rows, and attach a valid-from, a valid-to, and a recorded-at timestamp to each row. Wrap every read behind a single function that takes a point in time as an argument. Skip that layer and every caller writes its own ad-hoc condition, and one will eventually confuse the two axes.

## Splitting Types Is a Discipline, Not a Library

The four incidents covered here, timezone drift, timeout storms, duplicate batch runs, unauditable history, look like unrelated problems on the surface. Different teams own them, different investigations uncover them. Peel back one layer of code, though, and the same mistake shows up: two concepts with different arithmetic collapsed into a single type, a single column, a single variable.

A good library genuinely helps. A language that exposes instants and wall-clock readings as distinct types catches roughly half these mistakes before code ships. But a library cannot substitute for discipline. Storing an offset instead of a region identifier, keying a scheduler on execution time instead of a span, keeping one time axis in a history table: each is a human design choice. A type system can warn you after the choice is wrong. It cannot make the choice for you.

Which leaves one practical check that generalizes across all four cases: every time a time value shows up in code, ask whether it is an instant, a wall-clock reading, or a duration, and if a duration, whether it is fixed or calendar-dependent. If the answer does not come immediately, that variable is probably living in the wrong type. Turning that question into a review habit prevents more incidents than adopting the newest library ever will.

Time bugs linger longer than most bugs precisely because they stay quiet. Quiet, though, does not mean complicated. In every case here, the root cause was the same sentence: two different things poured into one container. Separate the containers, and half these incidents stop being expressible in code at all.
