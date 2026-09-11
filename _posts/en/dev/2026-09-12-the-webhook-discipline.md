---
title: "Webhooks Don't Fail Loud. They Fail Quiet."
excerpt: "Webhook failures do not shout. The crash is the safe failure, because it returns a 500 and the sender retries. The dangerous one is the endpoint that answers the wrong status code once and lets a message disappear without a trace. The sender's only promise is at-least-once delivery, and this post argues the four devices the receiver must build to match that contract."
seo_title: "Webhook Receiver Discipline: Trust, Duplicates, Response Codes, Dead Letters"
seo_description: "A webhook URL is a public address and duplicates are the normal case. Signature verification, the idempotency table, response-code discipline, and the dead-letter routine to have in place before you open the endpoint."
date: 2026-09-12
last_modified_at: 2026-09-12
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - webhooks
  - signature-verification
  - idempotency
  - at-least-once
  - dead-letter
  - response-codes
  - solo-developer
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-webhook-discipline/"
ebook: /assets/ebooks/the-webhook-discipline.pdf
ebook_title: "The Webhook Discipline"
ebook_pages: 33
---

This post is for solo developers and small SaaS teams that connect external services, payments, GitHub, notifications, through webhooks. What you get from it is one account: the sender's only promise is at-least-once delivery, and everything else is built on the receiving side.

Conclusion first. Webhook failures do not make a sound. The crash is the safe failure. It leaves a 500, and the sender redelivers. The dangerous one is the endpoint that throws no error and simply answers wrong: the letter disappears quietly, or the sender keeps delivering the same garbage forever.

The recurring scene. Day one, the test event arrives and the dashboard turns green. Day two, the first real event fails signature verification. Day three, the same event arrives again five seconds later and the customer gets two license emails. Day five, after a redeploy, a refund lands before the payment it refunds, and the final state is 'licensed.' None of the four events is an anomaly. All four are the sender working normally. This post argues the receiver devices that match that contract, in order.

![Illustration of the core idea of Webhooks Don't Fail Loud. They Fail Quiet.](/assets/images/the-webhook-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## The sender's only promise is "at least once"

Polling is you knocking on the sender's door every minute. A webhook is the sender knocking on yours when something happens. The direction of control flips. In polling you own the timing and the other side merely answers. In webhooks the other side owns the timing and you have to be the one who receives. The design burden moves from 'when do I ask' to 'how do I receive whatever arrives'.

The promise the sender makes to you is exactly one: at least once. Not exactly once, and not in order. The sender redelivers if it does not get a 2xx within its timer. Say your processing succeeded but the response packet was lost in the network. The sender's timer runs out first. The same letter arrives twice. Both times are legitimate behavior.

The retry is double-edged. Used well, the sender's retry is your safety net. Your database can be down for twenty minutes and the letter is not lost; the sender holds it and keeps knocking. Used badly, a bug in your handler makes every retry hit the same wall. Retry counts and total windows vary by service, and most do not exceed a day or two [estimate].

So the design premise is explicit. Messages may arrive many times, out of order, not at all, or forged. Design on the 'exactly once' assumption and the system breaks at the first retry. Against those four possibilities the receiver keeps four promises: trust the sender, do not duplicate, do not lose, do not collapse.

## The mailbox is a public address. Verify the sender

A webhook URL shows up in server logs, on vendor settings screens, in proxies. Anyone who knows the URL can assemble a 'payment complete' message and deliver it. The forger needs no secret; it only needs to copy the JSON shape. Process the body as-is and the forger has bought your product for free.

An IP allowlist is not a sufficient answer. Senders run several IP ranges and change them without notice. Hardcode the list and your endpoint dies the day they migrate: you discard everything outside the list, so on migration day every real event is discarded.

The real answer is a signature. You and the sender share a secret. The sender hashes the message with that key and sends the hash in a header; you recompute with the same secret, and a match means the letter was written by someone who knows the secret. The secret itself never crosses the network. Only its effect does. That is what makes forgery expensive. The algorithm is almost always HMAC-SHA256.

The temptation is to skip the standard: 'just append the secret to the body and run SHA-256.' Do not. An attacker who knows the hash structure can, without knowing the original hash or the secret, produce the hash of a new message with arbitrary data appended to the body. HMAC avoids the problem structurally by running the hash twice and seeding the secret in both branches. When a standard exists, there is no reason to invent your own authentication.

In practice, the signed string is where implementations break. The signature is computed over the raw bytes exactly as sent, not over the value your code parsed and re-serialized. One space or one reordered key changes the hash: the classic 'works locally, fails only in production' bug. GitHub prefixes its HMAC of the raw body with sha256=. Stripe folds a timestamp into the signature and signs 't', a period, and the body. The two signature strings must be compared in constant time; a plain equality check lets an attacker match the hash byte by byte by timing responses.

The remaining attack does not forge. It steals a real letter: the replay. A valid signature and body can sit in your server logs or a proxy, and resent later it passes signature verification. It is a genuine letter. The defense has two layers. First, time: when a timestamp participates in the signature, any letter older than a fixed window, typically five minutes, is invalid. Second, the duplicate check: the replayed letter carries an event id, and an id you have already processed marks it stale. The signature answers 'is it real?' The duplicate table answers 'is it new?' Replay is an intentional duplicate.

## Duplicates are the normal case, not the exception

For a webhook receiver, duplicates are the normal case. The sender promises at least once. So the endpoint has to satisfy two conditions. Processing the same letter twice must yield the same result, and a late or out-of-order letter must not corrupt state.

The simplest structure is a table of the event ids you have already seen. When a letter arrives, insert its event id. A successful insert means first time; a duplicate-key failure means you have it. The primary key is the filter. Duplicate letters must also get a 2xx. The sender stops retrying only when it sees a 2xx. Answer 400 to a duplicate and the sender delivers duplicates forever.

Ordering matters. Write the event to the table before you return the 200. Process first and write later, and you can die in the gap: the letter is lost, and you never know it was lost. Keep a 'received but not processed' status and the table becomes your queue. On startup you re-read the pending letters, and letters in a table survive restarts.

One trap in the duplicate table: retention. Left to grow forever it becomes a useless stone tower. A cron that deletes rows past a retention period set from received_at is enough. But the period must be longer than the sender's maximum redelivery window. If the sender retries for three days and you delete records after one, the day-three retry is treated as a brand-new letter.

The duplicate table stops only letters with the same id. It cannot stop the same fact arriving with different ids. You issue a license on a 'payment succeeded' event, and later an 'invoice paid' event for the same payment arrives. One fact, two types, two ids. If the logic says 'add one license,' it adds two. If it says 'set the customer's state to licensed,' the result is one no matter how often it runs. Adding a coupon is an operation; setting a flag is a state. The duplicate table is the first line of defense; idempotent logic is the last.

Now order. Your server was briefly down, so a 'refund' arrives before the payment it refunds. You try to refund a license you never issued and fail, then 'payment complete' arrives and you issue the license. Final state: licensed, while the customer has refunded. A structure that leaks money. The answer is a state machine. Allow only legal transitions, and when an unknown one arrives, do not guess; ask the sender's API for the current state. The webhook body is a snapshot; the API's answer is the present.

## Your status code is a command to the sender

What do you answer? The endpoint's response code is a command to the sender. 2xx means 'received, do not resend.' 4xx means 'this letter is malformed, stop sending it.' 5xx means 'my side is broken, send it again later.' A timeout is a 5xx. The code is not a report; it is protocol.

First rule: separate 'can't' from 'won't.' You won't when the payload is malformed, when you do not know the event type, when verification fails. A retry cannot change the content, so answer 4xx. You can't when the database is down, when a downstream API times out, when a bug throws an exception. A retry might succeed, so answer 5xx.

| Situation | Answer | Why |
|---|---|---|
| Verification failed, format wrong | 4xx | A retry cannot change the letter |
| Database down, downstream timeout | 5xx | A retry might succeed |
| Duplicate, already received | 2xx | Stops the sender's retry loop |
| Type never subscribed | 2xx plus loud log | Not your work, but worth knowing |

The most dangerous mistake is returning 200 for a 'can't.' The sender marks the delivery complete and never resends. The letter disappears quietly: no error, no log, no alert. You find out only when a customer writes that they paid and nothing happened. The silent failure is born from one status code. The second most dangerous is returning 500 for a 'won't.' The sender keeps resending a letter that can never succeed, and your logs and duplicate table fill with garbage.

What about an unexpected event type? It is the can't/won't question in another shape. If it is a type you subscribed to but have not written the handler for, answer 500: you want to notice that brokenness. If it is a type you never subscribed to, answer 200 and log loudly. The first is a bug you will fix; the second is a rumor from the outside world.

## When a letter dies: dead letters and replay

The sender's dashboard has a parking lot where failed deliveries sit. It is an aid, not a foundation. Entries can expire, the format can change, and finding a lost letter means logging into a vendor console. Keep your own records: the original letter, and what happened to it.

The key is storing the raw body. A body left in logs is your re-serialized value, and it can differ from what the sender actually sent. The raw bytes are the only source you can re-run through the same signature verification. Store the headers too, with the secret stripped.

When is a letter dead? A simple criterion: three processing failures, or more than twenty-four hours unprocessed. A cron that moves matching rows into a dead-letter table is enough. At that moment, alert yourself. What matters is not the channel; it is whether you notice.

The recovery procedure is fixed. First, fix the bug. Replaying a broken handler only produces more dead letters. Second, confirm the pipeline is alive with a known-good event. Third, resend in the original order, by received_at when there is more than one. Fourth, repetition is already safe, because of the duplicate table and idempotent logic. Fifth, reconcile the gap through the API. If the outage was long, there are events you do not even know the ids of. Ask the API for the current state of what matters. With the raw body stored, this whole procedure is a ten-minute job.

The numbers worth watching: three is enough. First, failure. The count of 5xx and exceptions in the last hour. Zero is good; a run of them means the problem is code, not network. When failures repeat, one line of code is wrong, and fixing it fast is an operational discipline. Second, stuck. The age of the oldest pending row, from its received_at. A letter sitting unprocessed means something is blocked.

Third, silence. The time since the last letter arrived. This one is subtle. A webhook stream has a baseline. A payment service that always delivers, suddenly quiet, is an abnormal signal: a changed URL, a rotated secret, an outage on the sender's side. Absence is also an event. Set the baseline from your system's normal quiet period. Set that constant carelessly and the silence alert becomes a false alarm every time. Three false alarms, and a human stops responding to alarms.

## Three tests before you open the endpoint

Before you hand the URL to the real world, test in three stages. First, a format test: build the payload yourself, sign it with your own secret, and POST it to the local endpoint. A twenty-line script catches bugs in raw-body handling, header parsing, and signature comparison. Second, a sender test: use the dashboard's 'send a test event' button and confirm that the secret, the URL, and the event subscription all mesh.

Third, a failure test. This is the stage most often skipped, and the one that proves the whole design. Answer 500 once, on purpose, and watch whether the sender retries and whether your duplicate table catches the second delivery. Do it before launch. If no duplicate appears in the test, one of two things is true: the sender does not redeliver, check the documentation, or your duplicate check does not work, a bug.

Before all of it, four questions for the sender's documentation. How do I know this letter really comes from them? What id uniquely identifies one delivery? What do they do if I never answer? What do they do if I answer 500?

The sender promises one thing: at least once. The rest is four devices on your side. A signature that verifies the sender. An idempotency table and a state machine that absorb duplicates and out-of-order arrivals safely. Status codes that tell the truth. A dead-letter routine that brings lost letters back. Set those four up before the endpoint opens, and the sender's retry machinery stops being a threat and becomes your safety net. If you want each promise developed with code and examples, the ebook 'The Webhook Discipline' builds exactly those devices across thirty-three pages.
