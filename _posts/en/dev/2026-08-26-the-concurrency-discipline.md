---
title: "Single Threads Are Not Safe"
excerpt: ">-"
seo_title: "Single Threads Are Not Safe: Concurrency Discipline from the Yield Point"
seo_description: "The bug that passes every test and fails rarely in production is not caused by the number of executors but by the number of yield points. One discipline, from lost updates to a solo developer's full-queue policy."
date: 2026-08-26
last_modified_at: 2026-08-26
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - concurrency
  - race-condition
  - system-design
  - event-loop
  - locks
  - backpressure
  - solo-developer
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-concurrency-discipline/"
ebook: /assets/ebooks/the-concurrency-discipline.pdf
ebook_title: "The Discipline of Concurrency"
ebook_pages: 29
---

This post is for the developer who has chased a bug that behaves perfectly in tests and fails rarely in production, and for the solo developer whose week never adds up no matter how tightly it is planned.

What you get is a single map. In any concurrent system, the cause of failure is not the number of executors but the number of yield points, the places where execution pauses and resumes. Two threads, one thread with an await, one human with a calendar, all obey the same law.

The point is short. A system that works only when it works is not a system that works ninety-nine percent of the time. It is a system where one percent is uncontrolled. Concurrency discipline is the art of removing that one percent in the design, not the art of finding it in the tests.

![Illustration of the core idea of Single Threads Are Not Safe](/assets/images/the-concurrency-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## The bug is not in the code order but in the execution order

A single-threaded program comes with one guarantee: the execution order matches the order you wrote it. Line one runs before line two, and the same input gives the same result every time. That guarantee is why bugs are debuggable at all. You can reason about a line because you know exactly when it runs.

Add concurrency and the guarantee disappears. The code is identical, but two executors interleave in different orders, and the same input now produces different results. Worse, the failure does not announce itself. There is no error message that says we were interleaved. The system just quietly returns a wrong answer.

This is what it means for a system to work only when it works. It works ninety-nine times, and once, in a different order, a counter is short by one or a payment runs twice. Your tests keep passing, because the failing order is not the one your tests walk.

Look at how the machine breaks the simplest piece of code. Increment the counter by one is a single line. The machine executes it in three steps: read the current value, add one, write the new value back. Three steps, not one.

So the bug is never the code is wrong. It is that there is a gap between the three steps, and something can fit in it. What fits in that gap is the subject of the next section.

## Interleaving: the only shape a failure can take

A race condition is a defect that exists only when two operations interleave. The interleaving is the failure. Each operation on its own is correct; what is wrong is the order in which the two run.

Count the possible orders in the counter example. Two threads, three steps each, six steps in total. The number of ways thread A can occupy three of those six slots is twenty. That is the full universe of what this toy case can do.

Nineteen of those twenty orders cause no harm. One loses an increment: A reads zero, B reads zero, both write one, and the result is one instead of two. One increment vanished. Engineers call this a lost update.

The point is how small this example already is. Two executors, three steps. Real code has dozens of steps, and the executors are not two threads but dozens of connections. The number of possible orders grows to a scale that no amount of testing or review can enumerate. You cannot list the failures, so the strategy of finding them by listing never works.

The first discipline follows from that. Do not enumerate orders. Either remove the interleaving point so nothing can fit in the gap, or make the section that must not be interrupted atomic. Pick one.

It is rare, so it is fine, is not an answer. Whether that one order shows up depends on load and timing, and it arrives at 3 a.m. when traffic doubles. You do not need to prove it can happen. You need to remove the gap that lets it happen.

## A lock is not the fix but the start of the discipline

A lock removes the interleaving point. While you hold it, no other execution enters the critical section, and the order that could be broken apart becomes atomic. In a sense, the lock is the machine enforcing keep the check and the act together for you.

But the lock creates new failures of its own. Deadlock, contention, code that is harder to reason about. And structurally, the moment you introduce a lock you have introduced one more piece of shared state: who holds the lock. Using a lock is not an exemption from the discipline. It is the start of it.

Rule one: keep the critical section small. Only the operation that directly touches the shared state goes inside; computation, I/O, and network calls belong outside. While you hold the lock, every other execution that needs the same lock waits. Put a database query inside and the section is tied up until the query finishes, and a slow query drags the whole system down with it.

A lock is a device that converts parallelism into seriality, and the price of that seriality is the time you hold the lock. So the first instinct is to pull the slow API call out.

But pulling it out opens a new gap. Between the release and the re-acquire, another execution can change the state. Your check was true, but by the time you act, the world has moved. The rule is therefore not pull it out, but pull it out, then verify the check and the act are still atomic.

If you cannot verify that, keep it inside. A slow safe section beats a fast broken one. Choosing this trade-off deliberately, every single time, is the entire critical section discipline. And rule two is one line: every path, including the exception path, must release the lock. One forgotten path and the rest of the system waits forever.

## A single thread is not safe

So far this has been about many threads running at once. But most systems do not run many threads. Web servers, chatbots, message processors, and most JavaScript runtimes have a single executor, and yet they handle dozens of requests in flight at the same time.

The reason is that there can be many tasks in progress. The event loop has a queue: when a task (network, disk, timer) completes, its callback is placed on the queue, and the loop pulls them off in order. The loop is a scheduler. It decides when each callback runs, but there is only one thing that runs them.

So where are the interleaving points? Exactly where execution yields the loop. In JavaScript, the await boundary. In Python asyncio, the await. In Node's callback style, the place where the rest of the work is handed to a callback and the function returns.

Yield and resume are the passageway through which any other execution can enter. Consider the classic break: two tasks share a cache that starts null. Both see null, both fire the fetch, and the later write wins. If the fetch is a read, you merely paid for a duplicate request.

If the fetch is a write, the story changes. Payment, reservation, allocation. The double execution from the earlier section is reproduced on a single thread. The mental model that single threads are safe is wrong here. A single thread is not safe. It simply has fewer interleaving points.

So the model to correct is this: safety is decided not by the number of executors but by whether a gap opens between the yield points. Even a single thread with a yield can have its check-then-act broken apart. You hold the lock across the await, or you serialize the section through a queue.

## Backpressure: the discipline when arrivals outrun processing

The event loop has a second failure site, independent of interleaving. What happens when work arrives faster than it is processed? The gap between arrival and processing is a queue, and an unbounded queue grows without limit.

Memory fills, latency stretches, and eventually the whole system stops. This is not a bug, it is physics. When the arrival rate exceeds the service rate, the queue grows, and nothing stops that growth until you stop it.

The discipline is to decide the full-queue policy before the queue is full. There are four standard choices.

Wait: push the order back and process in the original sequence. Drop: when full, refuse new arrivals and record that you did. Sample: when volume is excessive, keep only the essential subset and process at a reduced rate. Reject: say no up front and return an error to the sender.

Which one you pick depends on what is in the queue. A duplicate read can be dropped; a payment write cannot. If order matters, waiting is right. What all four share is that the decision is made in advance. Deciding at the moment the queue fills is too late, because at that moment the queue is already full and the system is already failing.

The most common practical mistake is a queue with no depth. The code assumes the queue is always shallow and carries no guard for the moment it grows deep. So the check is simple: for every queue in your system, you should be able to answer what happens when it is full in one line. If you cannot, that queue is a time bomb.

## A solo developer is a concurrent system

Up to here the talk has been about code. But for a solo developer, concurrency is not only a thread problem. A one-person operation is itself a concurrent system: many tasks arrive at once, there is one executor, there is no redundancy, and if it breaks, there is no one to take over.

The law of the break is exactly the law of the code. Systems engineering calls a structure where the failure of one element stops the whole system a single point of failure. A one-person team has exactly one such element, and it is the person. Sleep, illness, a meeting, an urgent errand: all of them are a process suspension.

While you are suspended, the queue of unfinished work keeps growing. This is not a matter of working hard enough. It is structure. A single-executor system cannot avoid serializing, so the question it must answer is not how much can I do, but in what order, and when do I refuse.

The queue discipline from the previous section applies verbatim. The one difference from code is that here the queue is visible: the work board, the to-do list. Keep it invisible and the queue lives in your head, where its depth cannot be measured. What you cannot measure, you cannot set a full-queue policy for.

This is why a solo developer falls in the same places a multithreaded system falls. The structure is the same. The shared state is one head and one calendar. The interleaving points are the interruptions, the messages, the meetings. The check-then-act is I confirmed this is right, followed by a changed plan and an executed action. The unbounded queue is the head.

The only difference is scale. Code interleaves on the millisecond; a person interleaves on the day. The law does not ask about scale. So the review checklist is the same one: where in this week's plan can something interrupt? What did I confirm and then act on after the confirmation stopped being true? Where is the queue, and what happens when it is full?

## If you take only one rule

Pull it together. In a concurrent system, the failure lives at the yield point, not at the executor. So the first check is to find every yield point in the code: every await, every callback boundary, every place that hands execution to something else.

At each one, ask a single question: what can fit in here? If the answer is nothing, you need evidence, not intuition: a lock, a queue, an atomic section. If the answer is anything, and the section is a check-then-act, that spot is a race condition waiting for the right load.

The second check is the queues. For every queue in the system, one line: what happens when it is full? If you cannot answer, you decide now, not when it fills.

The third check is on yourself. A one-person system is a concurrent system too. Make the queue visible, give it a full policy, and review its interleaving points in the same language you review code.

A system that works only when it works is not a system that works ninety-nine percent of the time. It is a system where one percent is uncontrolled. The discipline is not more tests. It is removing the places where the order can differ in the first place. The companion PDF, The Discipline of Concurrency, walks the same map in more depth, from the anatomy of a race condition to the price of a lock.
