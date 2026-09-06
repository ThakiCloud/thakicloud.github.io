---
title: "Your Log Is an Answer You Wrote in Advance"
excerpt: "At 2 a.m. the alert arrives and there is no one to ask, while your own memory is half gone and more certain than it has any right to be. This piece argues that a log line earns its value at the moment it is written, not the moment it is read, and walks through the discipline that makes a solo developer's logs worth waking up for: levels as promises, structure as search, the five structural lies, and the drill that builds trust."
seo_title: "The Solo Developer's Logging Discipline: Write, Find, Believe"
seo_description: "A log is not a byproduct of code but an answer to a question you will ask later. The 2 a.m. test, level promises, the five-field structured line, and the five ways logs structurally lie, each with its antidote."
date: 2026-09-06
last_modified_at: 2026-09-06
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - logging
  - structured-logging
  - incident-response
  - solo-developer
  - observability
  - production-operations
  - sre-practices
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-logging-discipline/"
ebook: /assets/ebooks/the-logging-discipline.pdf
ebook_title: "The Logging Discipline"
ebook_pages: 32
---

This piece is for the developer who runs a production system alone, with no on-call colleague and no support desk open at night. Read it and you will get a single standard for telling whether your logs are evidence or rumor, plus the order in which to fix what fails the standard.

The claim, up front: a log is not a record of what happened. It is an answer you wrote in advance to a question you will ask later. The past remains only as far as the logs kept it, so anything never written down is, at 2 a.m., indistinguishable from something that never happened.

When the payment error rate crosses five percent in the middle of the night, the next thirty minutes run on four questions: when did it start climbing, which requests are failing, is the failure inside your code or outside of it, and does it connect to anything you touched yesterday. If those answers are in the logs, the night is survivable; if not, it becomes a guessing game. Everything below is one thesis argued end to end: a log line's value is decided when it is written.

![Illustration of the core idea of Your Log Is an Answer You Wrote in Advance](/assets/images/the-logging-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## At 2 a.m., Your Memory Is the Least Reliable Witness

In a team, the first instrument of a failure is a question. Did anyone deploy last night? Did anyone touch the config? Two or three questions and the cause narrows, because colleagues are living documentation. A solo developer has exactly one living document: themselves, and the 2 a.m. version is a dangerous source. You remember the deployment. You do not remember whether the worker restarted, or what you clicked in a browser tab in between.

The deeper problem is that memory feels like fact. Certainty and fact are different things, and a tired 2 a.m. has no energy left to tell them apart. A conclusion built on "I think I deployed last night" is an emotion wearing the costume of evidence, and when that emotion drives the next action, the incident grows one step longer.

So you need a witness that does not forget, and that witness is the log. A log is a design, not a byproduct. It is not born the moment you add a print statement; it is decided at coding time which lines survive where, in what shape, at what level. If you do not decide, the system stays silent when it breaks, and silence is the worst testimony there is.

Two versions of the same situation make the difference concrete. A payment request succeeds after fifteen seconds, and the user complains about the delay. The thin system has written two lines, and they prove a success and nothing else. Where the fifteen seconds went is not in the record, so answering the complaint means re-reading the retry logic, opening the vendor dashboard, and digging through memory.

```
[14th 09:12] request ok
[14th 09:12] request ok
```

That conclusion costs forty minutes drawn entirely out of yourself. The disciplined system has written four lines instead: the call starts, fails with a 502 and a 3120 millisecond latency, schedules a retry for fifteen seconds, and the second attempt succeeds in 210 milliseconds.

```
09:12:31 INFO payment call start provider=stripe request_id=req_9f2k attempt=1
09:12:33 ERROR payment call failed provider=stripe request_id=req_9f2k status=502 latency_ms=3120 attempt=1
09:12:34 INFO retry scheduled request_id=req_9f2k next_in_ms=15000
09:12:47 INFO payment call succeeded provider=stripe request_id=req_9f2k latency_ms=210 attempt=2
```

The four lines explain the fifteen seconds without asking anyone. The point is not the number of lines. It is whether the relevant lines survive, in a shape that shows they are relevant, in a place you can find later.

<!-- nlm-visual -->
![Key-concept summary infographic 1](/assets/images/posts/news/the-logging-discipline/en/nlm-infographic-1.webp)
*Infographic generated by NotebookLM from the sources.*

## Levels Are a Promise to the Reader

At first everything is important, so every line is INFO: server started, request received, batch finished, all at the same eye level. The result is a hundred thousand INFO lines a day, and the line you need at 2 a.m. is in there. You cannot find it, not because it is absent, but because a hundred thousand identical lines are also present.

A level is a promise to the reader: how urgently should I act when I see a line at this level. ERROR means get up; WARN means look at it today; INFO means read it when you need the flow. Break the promise and an ERROR makes you wonder whether you should even check; you check, and it is an ERROR again. At that point the reader stops trusting the level, and a system whose levels are not trusted is no different from a system with no logs.

A solo developer gets to define the promise simply, because there is exactly one reader.

| Level | Meaning | Expected frequency |
|-------|---------|--------------------|
| DEBUG | Development detail | Dozens per request |
| INFO | Normal events | A few per request |
| WARN | Abnormal but self-recovered | Occasionally |
| ERROR | Failure that needs action | Target: zero |

The real value of the table is the last row. A system that emits ERROR several times a day is not healthy; it has diluted the meaning of ERROR. The moment you think "that line again, I suppose that is fine," the promise is broken. So keep one rule: ERROR is the line you want to wake up for.

Ask it once per line: if I see only this line at 2 a.m., can I act? On a payment failure, the difference looks like this.

```
ERROR payment failed
ERROR payment call failed provider=stripe status=502 latency_ms=3120 request_id=req_9f2k attempt=2
```

The first line says something failed. The second says what, where, how, and which request: Stripe threw a 502, and this was the second attempt. The distance between starting the investigation and reaching a judgment is the distance between those two lines. A line that fails the test asks the reader to fill in blanks, and blanks are filled with context, which is worst exactly at 2 a.m.

## Write Lines the Machine Can Find

A free text line like "payment-api 2026-03-14 09:12:33 ERROR request req_9f2k failed" is readable, but only by people. To find every failed request on the 14th, you have to remember where the request id sits in the line and match a pattern. Shift the field order by one slot and the grep breaks.

Free text falls to two diseases. Format guessing: the position of fields differs line to line, so every search starts with an eyeball check of the format. Vocabulary guessing: the same event is written as failed, or error occurred, or could not complete. A search is a pattern, patterns are fragile to variation, and one missing word removes that line from the evidence. The cure for both is the same: give the value a name.

A structured log is a line whose values carry names.

```
{"ts":"2026-03-14T09:12:33Z","service":"payment-api","level":"ERROR","msg":"payment call failed","provider":"stripe","status":502,"latency_ms":3120,"request_id":"req_9f2k"}
```

This line has two readers. The msg field is the part people read: payment call failed. The rest is the part machines search: every line with status 502, every line with provider stripe, every line with a given request id. Keep the shared field set at five: ts, in UTC; service, the component; level, the promise; msg, the human sentence; request_id, the correlation. Event-specific fields, provider, status, latency_ms, layer on top.

Keep one JSON object per line. If the JSON spans lines, line-based tools cannot count it, rotate it, or tail it. Field names need a promise too: lowercase snake case, common names for common fields, and renaming is a breaking change. If one service writes request_id as req and another as correlation_id, the values agree but the search becomes a guess again. Names are decided once and never changed; when something must be fixed, keep the name and fix the value.

request_id does the work of the correlation key. One request crosses three services, and without the key the three streams are three islands that do not know each other. Create the id at the entry point, hand it across every service boundary, and a single search gathers the scattered lines into one story, in order. Read the story and you know why the user waited fifteen seconds: a first 502, a fifteen-second retry wait, a second attempt that succeeded.

```
payment-api 09:12:31 INFO request received
payment-api 09:12:33 ERROR provider call failed status=502 attempt=1
worker 09:12:34 INFO retry scheduled next_in_ms=15000
payment-api 09:12:47 INFO payment succeeded attempt=2
```

## Logs Lie in Five Ways, and Each Has an Antidote

"The log is the truth" must not be a slogan. The ways logs lie are structural, not accidental. Five common lies are already known, and each has a known antidote. Knowing the faces narrows the suspicion: if the order looks reversed, suspect the clock; if the last line is missing, suspect the buffer; if one timestamp means two moments, suspect the format.

First, clock skew. Two servers whose clocks differ by thirty seconds can reverse what happened first: A called B, but the log shows B first. Root-cause analysis begins with order, so a wrong order produces a wrong cause. The antidote is NTP: every machine time-syncs, and is occasionally compared against a public time source.

Second, the lost tail. A force-killed process never delivers its buffered lines to disk, and the last few lines are gone. The lines just before death are very often the most important ones. A line that exists only in memory is a line that has not been written. The antidote is flush: ERROR lines go to disk immediately, or the buffer interval gets short.

Third, mixed time zones. Some lines UTC, some local, and 09:12 means two moments. Store in UTC, display in local. Fourth, sampling that eats errors. Thin lines to save storage and the thinned lines may be exactly the ones you need, because rare lines are the valuable ones. Never sample ERROR or WARN; thin only INFO and DEBUG.

Fifth, the line that was never written: not dropped, not lost, simply absent from a code path. The request hangs, there is no last line, and the answer is nothing. The antidote is boundaries: write the entry and exit of every stage, so the missing line reveals its position.

Analysis that reads only existing lines misses the most important evidence, because evidence is also in the absent line. Find the last line in the problem service's time window and ask what you expected next. If the last line is request received at 09:12:31 and provider call start never appears, the process died in the gap between the two. With boundaries written, the last log is a position, not a hint.

## What You Do Not Write Is Discipline Too

The discipline covers not only what to write but what to keep out. The first kind is safety. Secrets, API keys, tokens, passwords, never enter a log. A log that has carried a secret once is contaminated forever: it replicates to the log service, to backups, to archives, and the path of contamination cannot be traced back. One mistake is enough.

Full personal data stays out as well. Diagnosis needs which request, not which card. An identifier and a length are enough: the length says it was a 16-digit card, the identifier says which user, and the number itself is not recorded. Full payloads for the same reason. A 500-kilobyte request body written in full bloats storage and fills the line with noise; size, identifier, and the fields that matter are enough.

The second kind is signal. The biggest noise is retries and polling. A polling worker that writes "no new work" every minute produces 1,440 lines a day, roughly 43,000 a month [estimate]. They are true, and they are worthless to search. The policy: the first occurrence is a line, the count is a field.

Retries follow the same shape. Do not write one line per attempt. Write the first failure, a summary carrying the attempt count, and the final result. The attempts field stands in for the middle, because a repeat written per line dilutes the signal by the number of repeats. Counts in fields; events in lines.

There is a budget for volume too. A request that finishes normally should cost about three INFO lines: start, boundary, success. If a request produces twenty, ask how many of the twenty you would need at 2 a.m.; usually fewer than three, and the rest belong to DEBUG. With a budget, deleting lines is permitted without guilt, because cutting lines is the same act as raising the signal.

## Trust Grows in Drills, Not in Reading

Whether you may believe what you found is the heaviest question. A log that can be found but lies is more dangerous than no log at all, because it supplies false certainty. False certainty drives false action, and false action lengthens the incident. But trust does not grow by reading logs; it grows by drill.

The drill takes fifteen minutes a week. Take one incident from last month, or one recent alert, and answer it from the logs alone: what, when, which request, why. If the answer comes out, the logs are true for that case. If it does not, write down the line you wanted and did not find; that line is next week's work. The drill is cheaper than a meeting, and it finds the gap nobody else can find, because you are the only person who writes these logs.

When a log fails you, do not reflexively blame it. The failure has three different faces, and the responses differ. First, the log was missing, so the incident was unknown; the response is a new line next week. Second, the log was there and the incident was outside the system, a vendor outage, network, DNS; the log did its job, and the witness for the outside world is the vendor dashboard. Third, the log was present and deceived you, skew, sampling, loss; the response is the antidotes above.

Close every incident with a three-line note: what happened, what evidence, what changed. The evidence is written as a query, not as a feeling. "Searched ERROR for the last 15 minutes, confirmed provider 502" is a note; "felt like the payment vendor" is not. Fix the shape: incident name, time window, one line of cause, one line of query, one line of action. Fixed shapes let future notes search past ones.

End with an inspection of the system you have today: do ERROR lines wake you at 2 a.m., or fire daily? Can you act from a single line? Do all lines carry ts, service, level, msg, request_id? Does every stage have an entry and an exit? You do not need to answer all of them this week; each one answered makes the next 2 a.m. a little easier. The argument above, expanded chapter by chapter with checks at the end of each, is the ebook that accompanies this piece.

<!-- nlm-visual -->
![Key-concept summary infographic 2](/assets/images/posts/news/the-logging-discipline/en/nlm-infographic-2.webp)
*Infographic generated by NotebookLM from the sources.*

## References

The log levels, time synchronization, one-JSON-per-line format, request-id propagation, and rotation claims in the body cross-check against these materials.

- [RFC 5424: The Syslog Protocol (IETF)](https://datatracker.ietf.org/doc/html/rfc5424)
- [logging: Facility for logging in Python (Python docs)](https://docs.python.org/3/library/logging.html)
- [JSON Lines (jsonlines.org)](https://jsonlines.org/)
- [Context propagation (OpenTelemetry)](https://opentelemetry.io/docs/concepts/context-propagation/)
- [Network Time Protocol (Wikipedia)](https://en.wikipedia.org/wiki/Network_Time_Protocol)
- [logrotate(8): Linux manual page](https://man7.org/linux/man-pages/man8/logrotate.8.html)
