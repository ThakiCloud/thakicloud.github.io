---
title: "Money Systems Break Silently: Making Every Billing Failure Visible Within a Day"
excerpt: "A failed card charge leaves no crash, no error log, and no alert. The customer keeps using the service while that month's revenue quietly stops existing. This post argues why money systems fail that way and what it takes to make every failure surface within 24 hours."
seo_title: "Money Systems Break Silently: Billing Design for Solo Developers"
seo_description: "Why subscription billing fails without any error, and how an event-first ledger, an event-driven state machine, idempotency keys, and reconciliation make every failure visible within a day."
date: 2026-09-05
last_modified_at: 2026-09-05
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - subscription-billing
  - payments
  - webhooks
  - refunds
  - reconciliation
  - saas
  - solo-developer
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-billing-engineer/"
ebook: /assets/ebooks/the-billing-engineer.pdf
ebook_title: "The Billing Engineer"
ebook_pages: 31
---

If you are the one developer building a subscription product and handling the money yourself, this post answers one question. Payment incidents leave no crash and no error log, and the only thing you can engineer is the time between the failure and the moment you see it.

The customer's card expired last month. The system tried to charge on the billing day and failed, tried again two days later and failed again. Then nothing happened. No state change, no email, no log entry. The customer kept using the service all month, and that month's revenue does not exist. Open the admin screen and the subscription still shows active.

The worst failure mode of a money system is not the failed payment. The real danger starts when the system does not know that it failed. This post argues why billing failures are silent, and how an event-first ledger, an event-only state machine, idempotency keys, and a scheduled reconciliation job make every failure visible within a day. The goal is a system where no error can stay invisible past 24 hours.

![Illustration of the core idea of Money Systems Break Silently: Making Every Billing Failure Visible Within a Day](/assets/images/the-billing-engineer-hero.webp)
*A visual metaphor for the article's key idea.*

## What "Breaks Silently" Actually Means

Code a solo developer writes every day has one property: everything is inside one process. The database, the files, the state, all of it. When something goes wrong, you roll back. Money breaks this property in three ways.

First, the counterparty is outside your process. A charge request travels over the network to the payment service provider, the PSP, then to the card network and the bank. Each hop is a separate company with a separate failure mode and a separate clock. No transaction boundary can wrap the movement of money.

Second, time enters the system. Subscriptions have billing cycles, settlements have delays, and refunds take days to reach a card [estimate]. An API response is not the end. It means accepted, and the actual fact arrives later, in the form of an event.

Third, the effect cannot be canceled. A database row disappears when you delete it. Money can only be sent back after it has moved, and a refund is a new movement with its own failure modes. In a money system, reversing is always an event, never an undo.

Put the three together and one sentence follows. The assumption that information is complete and arrives in order does not hold here. Failures are not problems at the moment they break, they are problems over the period they accumulate. A proration error surfaces in the next billing cycle, a missed refund in the next settlement, a lost webhook at the next reconciliation.

## Truth Arrives Twice: The Response and the Event

A money system has two kinds of information. The API response means only that your request was accepted. A 200 on a charge request is a promise to bill, not evidence that money moved. Approval, settlement, and the state change on the PSP side are all still to come. The [webhook events](https://docs.stripe.com/api/events) are the facts of money, and they arrive asynchronously, [at least once](https://docs.stripe.com/webhooks), and out of order.

So there is one design rule. The subscription state machine moves on events only. A user clicking cancel and the API returning 200 is the acceptance of a transition request, and the actual transition is performed by the later event or by reconciliation. If a request handler still writes the subscription state directly, that path is a hole. Two sources of truth will diverge.

The most common incident goes like this. A customer cancels in the PSP portal, the PSP state becomes canceled, and a webhook is sent. That night your server is mid-deploy, the webhook gets a 500, and the PSP retries for days before giving up. Your database still says active.

Both outcomes are bad. The PSP stopped charging while the service stays on, the customer keeps using it, and no revenue exists. Or the reverse: charging continues while the customer believes the subscription is canceled, and the next step is a dispute. Neither leaves an error. What broke is the gap between what the system knows and what money actually did.

## Write the Ledger Before You Change State

One discipline to internalize from day one. Every money-related action, charge, refund, state transition, writes a row to a log table before the state changes. Call this log the money ledger. The minimum fields: event id, type, timestamp, amount as an integer in the smallest currency unit, previous and new state, PSP reference, and source.

A row looks like this: evt_00217, type invoice.paid, ts 2026-07-08T09:14:03Z, subscription sub_42, amount 33000 KRW, previous state open, new state paid, source webhook, PSP reference in_9f2c. This line is the only one that later answers what happened that day.

Webhooks are duplicated and out of order, and processing them in arrival order tangles the state. With the ledger you can re-derive the tangled state from the log, which becomes the only reproducible source of truth. When a customer says they paid but the service is off, you do not remember that day; the ledger remembers, and most disputes end at the step of reading the log in time order. The reconciliation job also needs the list of events you processed.

One practical warning: the event record and the state change must live in the same transaction. Change the state first, then die before the log write, and you have a state with no record, an unexplainable state. Log first, then die mid-transition, and you have a record without a state change, which you can replay. Always pick the side that can be rewritten.

## Four States Are Enough

The minimum subscription state machine has four states. Events are the only thing that moves them, and past_due must have a way out: the customer updates the card, a retry succeeds, and the state returns to active. Without that path, past_due becomes a waiting room in front of unpaid.

| State | Meaning | Service effect |
|---|---|---|
| active | Charging normally | Access allowed |
| past_due | Charge failed, retrying | Per grace policy |
| canceled | Renewals stopped | Access until period end |
| unpaid | Retries exhausted | Access suspended |

The state left out most often is [past_due](https://docs.stripe.com/billing/subscriptions/build-subscriptions). In a two-state world of active and canceled, a failed charge forces a binary choice. Cancel immediately, and you lose the customer whose card merely expired, with no chance to update it. Stay active forever, and you get the revenue leak from the opening scene. With no third state, money leaks quietly.

A failed charge needs a schedule with a final cutoff. Attempt one on the billing day, and on failure move to past_due; attempt two with a notification email at plus three days; attempt three at plus seven; a final attempt at plus fourteen, failing which the state becomes unpaid. Early intervals are short because most failures are transient, low balance, an expired card, a bank-side error. Late intervals are long because whoever is left there has a dead card or no intention to update. Without a cutoff, past_due becomes a permanent state and you can no longer answer whether a customer is paying.

The grace period, whether you keep the service on during failures, is a business decision. Write it down and tie it to state, never to time. Cut immediately on the first failure and you lose customers before their second chance; keep them forever and you leak revenue. Two emails are enough: the first-failure email with the PSP's [hosted card-update link](https://docs.stripe.com/customer-management/integrate-customer-portal), and a last-chance email before the final cutoff.

## Idempotency Keys for Duplication, Reconciliation for Loss

A payment request has three paths to duplication: your own retry after a timeout, a gateway retry from a setting you forgot you enabled, and the user's double click. All three try to execute the same payment intent twice. The rule is one key per payment intent. The client generates a UUID and sends it as the [idempotency key](https://docs.stripe.com/api/idempotent_requests), and the PSP returns the same result for the same key without charging a second time.

Without the key, a timeout is a mystery, because you cannot know whether the first request charged. With the key, a timeout becomes a missing piece of information, and resending with the same key is safe. But never reuse a key across intents. The key is the identity of an intent, not a token for economy.

The same trap exists in dunning, the management of failed charges. PSPs ship [automatic retry](https://docs.stripe.com/billing/revenue-recovery/smart-retries), and if you also build your own schedule, two retry engines run at once. One failure, retries from both sides, and the customer can be charged twice in the same cycle. Leave it to the PSP and keep your schedule as a fallback, or build your own and turn the PSP's off. Running both is not a design, it is luck.

Webhook retries cover short outages only. The PSP retries failed webhooks on widening intervals for a few days [estimate], and if your endpoint is dead longer than that, the event is gone forever. That is why reconciliation exists: a scheduled comparison, every night or weekly, of the subscription states the PSP believes versus yours, the invoice amounts and states, every refund request and result.

When a difference is found, one principle: trust the PSP. Its data is the state of the money; yours is a copy, and the copy is what is wrong. Record the fix itself as an event in the ledger, with source reconciliation. I paid but the service is off, or I canceled but I was charged again, are answered by the ledger plus the reconciliation diff. Without it, what remains is pasting bank deposits next to support tickets and matching.

## A Refund Is a Transaction, Not a Button

A refund request is the moment the money system is really tested. Charging can hide behind the PSP, but a refund is where your code, the PSP, and the customer's card all have to agree on the same number. The most common design mistake is making the refund a button. Click it, the state becomes refunded, and nothing has actually happened yet. A refund is a transaction with states: [pending, succeeded, failed](https://docs.stripe.com/api/refunds/object). Failed refunds actually happen, when the card expired, the account was closed, or the bank declined. A succeeded refund is not instant; it takes days to reach the customer's card [estimate]. Marking refunded at request time records a fact that may never occur; the state moves only on the result event.

The money you charged is not yet yours. The PSP collects it, holds it, and deposits it on a settlement cycle that varies by PSP and account [estimate]. Take an invoice of 33,000 KRW: a fee of roughly 4 percent [estimate] is deducted, and if you later issue a full refund, the fee does not come back [estimate]. A refund is not giving money back, it is giving money back and losing the fee. A disputed charge goes further: the [dispute fee](https://docs.stripe.com/disputes) is added, and if you lose, the amount is not recovered. That is why the refund policy must be priced with the fee structure known, and why you match book revenue against the actual deposits each month. If the difference is not explainable, a record is missing from the ledger.

Separate the two always-confused concepts: cancel and refund. Cancel stops future charges, and no money moves. Refund moves money back, and usually ends the current paid period. A large share of tickets titled refund are actually please stop billing me, and many cancel requests hide the expectation of getting money back. So the UI gets two buttons, the code gets two paths, and the first line of support asks which one the customer means.

When a refund request arrives, ask three questions in order. Is there a legal or contractual obligation? If one exists, the decision ends there. What does refusal cost: the dispute, the negative review, weeks of support conversation, and for a solo developer, time is the most expensive line item. What does granting cost: already-consumed usage, the PSP fee, and the precedent, because a policy that refunds everyone on request stops being a policy. Record the decision and its reason in the ledger; the next identical request gets answered with consistency, and that recorded reason becomes the evidence if a dispute comes.

## The Goal Is Visibility, Not Perfection

Why can errors not be prevented? Because the counterparty is outside your process, because time is inside the system, and because effects cannot be canceled. None of the three is under your control. An error-free money system is a prayer, not a design.

The goal is different: a system where every error is visible within a day. The ledger turns the accumulating period back into a readable log. The event-only state machine keeps a single source of truth. Idempotency keys remove duplication at the source. Reconciliation finds loss every night. Refund-as-transaction kills the no-op button. They all serve the same sentence: nothing can stay broken and invisible past 24 hours.

For a solo developer the target is higher than for a team, because the number of watchers scales with headcount. A team has an on-call engineer when the webhook dies at night, a person to run reconciliation, and someone watching the bank deposits. Alone, all of those roles are you. The refund email the customer sends at dawn is your alarm, and the first detector of a settlement mismatch is the banking app you open.

So two disciplines weigh more. First: there is no watcher that is not automated. A reconciliation job running on a cadence you cannot watch by eye is the same as not having one. Second: you must be able to read your ledger. When something breaks, the standard is finding the cause in your own records within ten minutes. The job where money passes is not to prevent every error, but to make every error visible within a day. As long as a broken bridge shows up in the ledger and on the reconciliation screen, the signal that the service is running fine is one you can trust. For proration edge cases and the tax boundary, see the companion ebook.
