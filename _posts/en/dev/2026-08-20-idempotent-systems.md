---
title: "There Is No Exactly Once, Only Idempotent"
excerpt: "When a payment request times out, most teams cannot say whether it is safe to retry. The problem is not the retry logic itself but the goal behind it: exactly-once delivery is not achievable over an unreliable network. This piece argues for replacing that goal with idempotent design, and walks through why timeouts carry zero information, how idempotency keys break in practice, and why database-level state transitions succeed where application logic fails."
seo_title: "Retry Safety Without Exactly-Once: An Idempotency Design Guide"
seo_description: "A timeout is not a failure, it is the absence of information. This piece covers idempotency key design, monotonic state transitions, and retry policy for building distributed systems that survive duplicate requests."
date: 2026-08-20
last_modified_at: 2026-08-20
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - idempotency
  - distributed-systems
  - retry-safety
  - api-design
  - backend-engineering
  - reliability-engineering
  - payment-systems
  - exactly-once
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/idempotent-systems/"
ebook: /assets/ebooks/idempotent-systems.pdf
ebook_title: "Systems That Are Safe to Resend"
ebook_pages: 30
---

If you have ever built a backend that touches money, orders, or anything else expensive to undo, you have already run into this question. A request goes out, no response comes back, and you have no idea whether it is safe to send it again. By the end of this piece you should be able to answer that question without hesitation. The answer does not live in a smarter retry loop, it lives in giving up on a goal that was never achievable in the first place.

Most teams design as if exactly-once delivery were the target: a request should arrive exactly once, be processed exactly once, and be acknowledged exactly once. That target is elegant on a whiteboard and impossible over a real network connecting two independent computers. Once you accept that it is impossible, the design actually gets simpler. You stop trying to guarantee a request is sent exactly once, and instead guarantee that sending it multiple times produces the same single outcome. That property is idempotency, and everything below builds toward it: why exactly-once fails on principle, where idempotency breaks down in real code, and the concrete techniques that hold it together.

![Illustration of the core idea of There Is No Exactly Once, Only Idempotent](/assets/images/idempotent-systems-hero.webp)
*A visual metaphor for the article's key idea.*

## What a Timeout Actually Tells You

When a request goes out and no response comes back, there are at least four things that could have actually happened on the server side. The request never arrived at all. The request arrived and the server started processing but died halfway through. The request arrived, processing finished completely, and the response was lost on the way back. Or processing is still in flight right now. From the client's vantage point, all four cases look identical. Nothing came back. That is the entire observation.

The important part is not that you are missing a little information. It is that you have exactly zero bits of it. Code that treats a timeout as a failure and routes it down an error-handling path is implicitly picking one of those four possibilities and betting on it. In the third case, where processing finished and only the response vanished, that bet is provably wrong. Retrying a payment that already went through produces a duplicate charge, not a safety net.

There is an uncomfortable corollary here. You cannot escape this by adding a status check before deciding whether to retry, because the status check can time out for the same reason the original request did. You cannot poll your way out of an information-theoretic hole. So the right response is not to eliminate timeouts, since a timeout is a structural property of asynchronous networks, not a bug. The right response is to make retrying safe regardless of which of the four cases actually happened.

## Why Exactly-Once Cannot Hold

Exactly-once sounds like a marketing promise, and under scrutiny it cannot be kept as a delivery guarantee. To make message delivery between two machines reliably happen exactly one time, sender and receiver would need to fully synchronize their state, and that synchronization is itself a message that can be lost. You end up needing a reliable channel to build a reliable channel. This is not a gap in current tooling but a limit understood in distributed systems theory for decades, and payment infrastructure gets no special exemption from it.

In practice you only get to choose between two options: at-most-once and at-least-once. At-most-once means that when in doubt, you do not send, giving up rather than risking a double send. At-least-once means that when in doubt, you send again, accepting the risk that the effect happens more than once. Most systems find duplicates cheaper to absorb than silent loss: a failed payment nobody notices is worse than a duplicate charge that gets caught and refunded. So production systems typically choose at-least-once delivery and build a layer on top guaranteeing the effect lands exactly once even though the message itself may arrive several times. That layer is idempotency.

It is worth being precise about what this buys you. You can make a system behave as if delivery were exactly-once by delivering at-least-once and filtering duplicates completely on the receiving end, but that behavior is manufactured at the application layer, not a property of the transport underneath it. That distinction is the entire argument of this piece: stop trying to make delivery perfect, and build a processing layer that tolerates delivery being imperfect.

## Who Should Generate the Idempotency Key

Before you can filter duplicates, you need a way to determine that two requests are, in fact, the same logical request. That determination rests on an idempotency key. The first place this breaks in practice is a question of ownership: who generates the key. The answer is unambiguous. The client that sends the request generates it. There is essentially no exception to this.

The reasoning follows directly from what a timeout means. If the server generates the key after receiving a request, the second, retried attempt gets a brand-new key. From the server's point of view those two attempts are now unrelated requests, and deduplication is dead before it starts. The only party that knows two requests are logically the same one is whoever created that logical operation, which is always the client. So the contract has to be: the client generates exactly one key per logical operation and resends that same key on every retry. The server uses that key, and only that key, to decide whether it has already handled this operation.

Even when teams understand this in principle, the contract keeps breaking in code for a predictable reason. If key generation lives inside the same function that builds and sends the request, calling that function again from inside a retry loop generates a fresh random value every time. Key generation has to happen exactly once, outside the retry loop, with the request builder inside the loop reusing that same value. If this boundary is not visually obvious in the code, someone will eventually move it inside the loop without realizing what they broke.

Hashing the request body to derive a key is another common mistake. It looks convenient, but it silently blocks legitimate cases where the same content is intentionally sent twice, such as wiring the same amount to the same person twice in a row. Same content and same logical operation are not the same concept, and conflating them turns a safety mechanism into a bug. Folding a timestamp into the key fails the same way, since the retry's timestamp differs from the original by definition, quietly generating a new key on every retry and defeating deduplication all over again.

## The Promise Never to Go Backward

An idempotency key store is powerful, but it is also one more piece of infrastructure you now depend on, and if that store becomes unavailable your defense goes down with it. There is a second line of defense that is cheaper and, in a meaningful sense, sturdier: make the data model itself indifferent to retries, with no extra storage required.

Take an order that moves through states in a fixed order: created, paid, shipped, delivered. Add exactly one rule: state can only move forward, never backward. The update statement then reads: only transition to paid if the current state precedes paid. If the same request arrives twice, the first satisfies the condition and moves the state; the second finds the state already paid, fails the condition, and changes nothing. Retries become safe without any separate key store.

Monotonicity is not limited to a single status string. It shows up in several shapes. Ordered state values that can only move forward is one. Flags that, once true, never flip back to false is another, which covers values like shipped or approved. Accepting only updates with a strictly greater timestamp or version number is a third, and it has the useful side effect of automatically discarding stale messages that arrive out of order. Adding elements to a set without ever removing them is a fourth, since inserting the same element repeatedly leaves the set in exactly the same state.

## The Trap Hidden in Read, Decide, Write

The single most common way monotonic transitions break in practice is where the condition gets checked. If you read the current state, let application code decide what to do based on that value, and then issue a separate write, you recreate the exact gap this pattern was supposed to close. Anything can slip in between the read and the write. Two concurrent requests can both read a pre-paid state, both conclude the condition holds, and both proceed to write, so the transition ends up happening twice.

The fix is to put the condition inside the write itself, not in a preceding read, and let the database treat the condition check and the update as a single atomic operation. When the query says update to paid only if the current state precedes paid, and that condition lives inside the update statement, only the request that arrives first actually satisfies it, and the other is filtered out automatically. Application code never gets a chance to decide on stale information, because the database evaluates the condition and performs the write in the same indivisible step.

There is one more thing to check every time, and it is the part that gets skipped most often: how many rows the update statement actually touched. If that number is zero, the transition had already happened. That is not an error, it is the normal, expected shape of a duplicate being handled correctly. A surprising amount of production code fires the update, sees it executed without throwing, and declares success without inspecting the affected row count. Ignore that count and you lose the only signal telling you whether this request was new or a duplicate, so downstream logic can end up re-executing side effects for work already done.

It is also worth being honest about what monotonic transitions cannot cover. Partial failures spanning more than one database transaction, such as a payment provider call succeeding but the process crashing before the local database records it, are not solved by monotonicity alone and need an idempotency key working alongside it. The two defenses are not substitutes for each other. They close different failure points, and a system with only one of them still has a hole.

## Retries Are Not Free Either

Making the receiving side safe does not mean you are free to retry as aggressively as you want. Poorly designed retry behavior is itself a common cause of outages, and badly tuned retries are one of the most common ways a small, localized failure turns into a large, systemic one. If a server is already under load and every client retries at the same moment, that traffic can eliminate the very window of time the server needed to recover.

The first rule is that not every failure should be retried. A retry does not fix invalid credentials, it just fails again the same way. A malformed request will fail identically on the second attempt too. Retrying failures like these burns server resources and only delays the inevitable result. Transient overload and momentary network drops, on the other hand, are exactly what retries are good at resolving. This decision should live as an explicit table in code, not as an ad hoc judgment call scattered across handlers: connection failures get retried because the request never reached anyone, server overload gets retried because it is transient, and authentication or malformed-request errors do not get retried because retrying them changes nothing.

Timeouts are the one entry in that table that is genuinely conditional, and the reason traces directly back to the first section: you simply do not know whether the request reached the other side. If the receiving endpoint is idempotent, retrying is safe. If it is not, you have to fall back to a status check instead of a blind retry. The answer in that cell depends entirely on a property of the system on the other end of the wire, which is why the very first thing to verify when integrating any external payment API is whether it supports idempotency keys. If it does, timeouts can be retried safely. If it does not, every single timeout against that integration requires a human to step in, and there is no way around that until the property on the other end changes.

Retry intervals matter just as much as the retry decision. A fixed interval with no randomness is dangerous, because a batch of clients that timed out at the same moment will all come back at the same interval and hit the server with a synchronized wave of traffic exactly when it has no room to absorb one. Growing the interval over successive attempts and adding a bit of randomness spreads retries out so they do not arrive as a spike. When the server tells the client whether a failure is retryable and how long to wait, client implementations get simpler, because the decision rests on information the server actually has rather than the client's guesswork.

## What to Check First

Everything above compresses down to one decision. Stop trying to achieve exactly-once delivery, assume at-least-once instead, and build a layer that guarantees the effect only lands once. That layer has two parts: an idempotency key the client generates and hands to the server, and a monotonic state transition baked into the data model. Neither is sufficient alone. A key store closes the partial-failure gap but adds an infrastructure dependency. A monotonic transition is sturdy without extra infrastructure but cannot cover failures spanning more than one system.

The first thing worth auditing in an existing codebase is any logic split into three separate steps: read, decide in application code, then write. Wherever that pattern shows up is exactly where the next incident will start. The second thing to check is whether anything inside a retry loop gets regenerated on every attempt. Whether it is a random value or a timestamp, if any part of the key changes between retries, what you have is idempotency in name only. The last thing to do is go through every external integration and ask whether that API supports idempotency keys. If the answer is no, that integration is, right now, requiring a human to intervene every time it times out, whether anyone has noticed yet or not.
