---
title: "Background Jobs Vanish Without Failing"
excerpt: "A queue is not a speed tool. It is the device that moves work out of the request path, and with that move a contract is born: when will it finish, and what happens when it fails. This post argues the discipline that keeps background work from disappearing unnoticed, from the boundary decision through job shape, the blind spots of failure, and a four-metric monitoring design for one-person teams."
seo_title: "Queue Discipline for Background Jobs: Boundaries, Idempotency, Dead Letters, and Four Metrics"
seo_description: "Where to draw the line between the request path and the queue, how to shape jobs so re-execution is harmless, and which four metrics wake a solo team only when something has actually been lost."
date: 2026-09-09
last_modified_at: 2026-09-09
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - background-jobs
  - job-queues
  - idempotency
  - dead-letter
  - visibility-timeout
  - observability
  - solo-developer
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-queue-discipline/"
ebook: /assets/ebooks/the-queue-discipline.pdf
ebook_title: "The Queue Discipline: Background Jobs"
ebook_pages: 33
---

This post is for solo developers and small SaaS teams that still do email, image rendering, and LLM calls inside the user-facing request. What you get out of it is one account: the real risk of background work is not that it runs slow, but that it goes away without you noticing. The rest of the post argues the discipline that keeps work from vanishing, step by step.

Conclusion first. A queue is not a speed tool. It is a device for pushing work that does not need to happen right now out of the request path. The moment work leaves the request, the system signs a new contract with the user: when will it finish, and what happens when it fails? A background job system is judged on how confidently it catches work that has stopped moving, not on how fast its jobs run.

The scene repeats. A user clicks a report button. Inside one request, the handler sends an email, renders an image, and calls an LLM. After thirty seconds the browser gives up, the user clicks again, and the email goes out twice, the image renders twice, the LLM is billed twice. Every step returned success. The logs contain nothing but evidence that nothing broke. Background job problems start in exactly this shape, and the cause is almost always a misplaced boundary. This post walks from that boundary through job shape, the blind spots of failure, and the metrics that keep a one-person team alive.

![Illustration of the core idea of Background Jobs Vanish Without Failing](/assets/images/the-queue-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## What Stays in the Request, and What Leaves It

The synchronous path is simple. A request comes in, gets processed, and a result comes back, with the user's screen blocked the whole time. Lookups, search, and payment authorization fit this path well. The user waits on the spot, the work is fast, and the decision is easy.

The asynchronous path returns one thing immediately: the fact that it was received. The work happens later, and the result arrives as an email, a status change, or a push. The user's wait time drops to nearly zero. In exchange, a contract is created, and the queue has to honor both terms: when it finishes, and what happens when it fails.

Which path is more modern is not the question. The questions that matter are how long the user can wait, and whether the service can afford to do the work later. If the user is watching the screen, the work is synchronous, even when it takes two seconds. Asynchronous is for work the user can walk away from.

When new work appears, ask a few questions before routing it. Does the user need to see the result right now? How long does it take? A rough guideline: under about 100 ms it is fine inline, and past one second it becomes a queue candidate [estimate]. The line matters less than what the line means: processing time is no longer in your hands. A database lock, an external API, a flaky network. Anything that can stretch execution past your estimate is a reason to leave the request path.

The temptation that blurs the boundary is speed. If the report is fast enough, it feels safe to keep it synchronous. But the criterion is the user's posture, not the duration. Work watched on screen stays synchronous at two seconds; work that can arrive later goes to the queue at thirty seconds. Speed alone does not move the line. The boundary is drawn before any tool is chosen.

## Jobs Must Be the Smallest Unit That Can Be Replayed

Once the boundary is set, the next question is shape. A queue is a list, and the quality of the pipeline around it is decided by two things: the shape of the work that goes in, and the loop of the worker that takes it out.

Job size determines the blast radius of failure. A job should be one unit of operation that can be safely replayed. There are three conditions. The input is unambiguous, the operation is single, and completion can be verified.

The common failure is bundling. An order processing job that pays, ships, emails, and grants points in one payload. If the email fails at the end, the retry reruns everything, and the package ships twice. The second box leaving the warehouse is the system working as designed, not a bug. When steps really depend on each other, the coordination belongs to a parent job or a state machine, and the children stay individually retryable.

A good job is a verb with one object. Sending one email is a job; contacting the customer is not, because you cannot say what it does, how it does it, or what completion looks like.

| Good job | Bad job |
| Send one email | Process the whole order |
| Resize one image | Payment, shipping, and points |
| One LLM call | Generate the full report |
| One step of a cancellation flow | Contact the customer |

Payloads carry references, not copies. Embedding a copy of the user record in the job creates a second version of the truth. The copy sitting in the queue and the state in the database will eventually disagree, and that disagreement is the source of bugs that are hard to find. The user changed their address; the job still holds the old one. Put the user id in the payload and fetch the fresh state from the database at execution time. The queue says what to do; the database says what is true now.

Enqueueing must stay cheap. If preparing a job requires fetching a file or calling an API at enqueue time, that preparation is itself a separate job. Enqueueing is a fast write. A heavy enqueue recreates inside the request path the long block this section is trying to remove.

## You Cannot Prevent Re-execution; You Can Only Make It Harmless

Workers die. Deploys, out-of-memory kills, panics. When a worker vanishes mid-job, that job was never acknowledged. Its visibility timeout expires, the job comes back, and another worker runs it again. This recovery is mandatory; it is the reason a queue survives at all. The price is duplicate execution. The side effect can happen twice.

So at-least-once delivery and idempotency sit at the center of the pipeline. There is no way to prevent re-execution. The only move is to make re-execution harmless. Idempotency means running the same operation any number of times leaves the system where one run would have left it.

Some operations are idempotent by nature. Setting an order's status to cancelled produces the same result on the hundredth run as on the first. Others are not. Adding loyalty points, sending an email, charging a card: each run stacks a new effect. Every non-idempotent step is a place where a retry becomes a visible error for a real person.

Idempotency keys: when a user double-clicks, the two jobs that arrive carry the same key and merge into one. Check-before-act: if the report row already exists, the job ends as a verification instead of a generation. Unique constraints in the database, where a duplicate-key error is read as proof that the work already completed, not as a failure. The double-click from the introduction stops its second email with one of these.

Do not confuse idempotency with retrying until something succeeds; that is a different disease. A job that retries forever occupies workers and hides the real failure inside a steady stream of attempts. Cap the number of attempts, and when the cap is reached, move the job to a dead letter queue. The dead letter is where a failed job waits, counted, until someone looks at it.

## Where Workers Die, and Where Jobs Stall

A background pipeline is quiet; when nothing goes wrong, it has no presence at all. Real skill shows up in the moment something dies. Work disappears through four angles: the worker dies, the job stalls without failing, the job retries forever, and the acknowledgment lands out of step with the side effects. Each angle needs a different net.

Worker death is caught by the visibility timeout, but the timeout is a range, not a value. It has to be longer than the longest job can run: with a thirty-second timeout and a forty-second job, a healthy worker's in-flight job gets stolen and runs twice. It has to be shorter than the time you can afford to lose: with a one-hour timeout, a dead job stays invisible for an hour. A reasonable starting point is two to three times the p95 execution time [estimate], tightened as you watch.

Death has another kind: memory. A job that expands a large image or holds an entire LLM response in memory can push the worker past its limit, and the process is terminated without writing an error. Because the job was never acknowledged, the visibility timeout brings it back. The net is the same as for a crash; only the cause differs.

A one-person team needs one more line: who restarts the worker? When the worker dies, restarting it is also somebody's job. A process manager like systemd that respawns a dead worker is baseline equipment for queue operation. Without a manager, a watchdog cron that checks whether the worker is alive is the next best thing. With neither, a dead worker is noticed by human eyes, and humans are not awake at 3 a.m.

The most stubborn angle is the job that stalls without failing. A job hung on an external API call throws no error; it simply never returns. The retry logic never fires, and nothing in the logs says it stopped. Only the visibility timeout notices that nothing happened; the range fixed earlier doubles as your stall detector.

## Acknowledgment, Side Effects, and the Dead Letter

The fourth angle is the gap between acknowledgment and side effect. The ack is written only after the effect is complete; an early ack means the work is done and never retried. When the effect spans several external calls, a crash between them leaves a partial result behind.

Order does the saving here. Put the calls that are hard to repeat last, and make the earlier ones idempotent. Email, then status update, then the card charge, rather than the reverse. A crash anywhere in the sequence then replays safely.

The angle of infinite retries is cut by the cap from the previous section. Without a cap, a failing job keeps circulating, occupying workers, and making a stuck queue look busy. The real failure hides behind the motion. With a cap, the job lands in the dead letter queue, where it waits, counted, for a reader.

Dead letters are read in the morning, and a pile carrying the same error is one incident, not a pile of failures. On the day an external API goes down, the jobs that exhausted their retries arrive in the dead letter together. The reading order is the same as before: check the external side first, then your own code. The moment the count moves above one, something a user asked for did not happen.

Put the nets together and the shape is clear. Worker death is caught by the visibility timeout and by the worker being restarted. Stalls are caught by the visibility timeout. Infinite retries are caught by the cap and the dead letter. The gap between acknowledgment and side effect is caught by order and idempotency. The nets differ; the work is the same. Every death is recorded somewhere.

## Four Metrics Are Enough for a One-Person Team

A one-person team has no 24/7 on-call. If the queue clogs at 3 a.m., the decision to get up is made in the moment, in the dark, without context. So the design goal of monitoring is precise: wake you only when there is something to do, and make the system checkable in five minutes during the day.

You do not need many metrics. Four are enough, and each answers a different question. The first is the wait time of the oldest job, the true onset of a backlog. A queue of five hundred jobs that drains within a minute is fine; a queue of five jobs that has been waiting three hours is an incident. The count is not the signal. The age of the oldest waiting job is.

The second is p95 processing time, looked at per job type. It is the early warning of degradation. The database slows, an external service slows, the worker ages, and this number grows first. Averaging the p95 of email with the p95 of LLM calls tells you nothing. Each type has its own shape, and the same metric must be read on a different scale for each.

The third is the retry rate, and it points outward. When the LLM API or the SMTP server has a bad day, this is the number that moves first. A sudden jump in retries is a signal that the outside is sick, and it changes the order of your investigation: check the dependency before you read your own code. It is a metric that tells you where to look.

The fourth is the dead letter count, and it is the only metric where one is already an incident. A dead letter is proof that a user asked for something and it did not happen. Zero is the state; anything above zero is a user-visible loss waiting for an apology. The other three are trends. This one is an event. Thresholds are starting points: oldest wait beyond an hour, p95 at twice the usual, retry rate above five percent, dead letters at one or more [estimate]. Tune them to the rhythm of the product; the usual for a nightly LLM batch is not the usual for minute-scale emails.

A queue is a device that makes later safe. Work leaves the request, and the system promises to finish it, to report when it fails, and to let no job disappear without a trace. The boundary, the small idempotent job, the visibility timeout with a range, the dead letter, the four metrics: that is the whole discipline of not processing everything at once. For the deeper version, the ebook accompanying this post covers the same territory with full examples, from the boundary questions to dead letter operations.
