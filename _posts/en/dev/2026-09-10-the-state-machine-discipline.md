---
title: "Status That Changes on Its Own Is a State Machine Without a Name"
excerpt: "Order, payment, and document status changes arbitrarily not because the code is bad, but because the state machine was never named and never gathered in one place. This post argues the explicit state machine end to end: naming states by what they wait for, keeping transitions as data with one function that runs them, and recording every move and every rejection in an append-only history."
seo_title: "The State Machine Discipline: Status That Does Not Change on Its Own"
seo_description: "Model orders, payments, and documents as explicit state machines: one status column, a transition table as data, pure guards, one apply function, and an append-only history that makes testing, debugging, and extension easy."
date: 2026-09-10
last_modified_at: 2026-09-10
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - state-machine
  - domain-design
  - backend
  - order-lifecycle
  - payments
  - testing
  - debugging
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-state-machine-discipline/"
ebook: /assets/ebooks/the-state-machine-discipline.pdf
ebook_title: "The State Machine Discipline"
ebook_pages: 35
audiobook: "https://drive.google.com/file/d/1rsTvo6BlWC9v0vclTKlH8EgYWkqkPdBR/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

This post is for backend and product engineers who own objects whose status flows: orders, payments, subscriptions, documents, approvals. What you get out of it is one argument, made in full: why status changes on its own, and the concrete design that stops it.

The conclusion first. Status changes arbitrarily not because the code is bad, but because the state machine lives unnamed, scattered inside if statements, never gathered in one place and never written as a table. Making the implicit machine explicit, readable as a table in one place, is the entire discipline this post argues for.

Consider what happens inside your system the moment an order moves from awaiting payment to paid. Most answers sound like this: somewhere, an if statement passed. Where that if statement lives, and how many there are, is usually nobody's knowledge. The not-knowing is the actual problem. This post argues the way from not-knowing to knowing, from the column mess to the append-only history table.

![Illustration of the core idea of Status That Changes on Its Own Is a State Machine Without a Name](/assets/images/the-state-machine-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## Why Status Changes on Its Own

The orders table has a status column. Its values are pending, paid, shipped, done, canceled. So far, so good. The trouble starts the moment you add a payment_status column to express failed payments, an inventory_checked boolean for stock checks, and a refund_requested flag for refunds.

Now status alone no longer answers "where is this order right now?" What on earth is an order whose status is paid, whose payment_status is failed, and whose inventory_checked is true? With five columns, the number of possible combinations is the product of the values in all five. Most of those combinations are impossible in reality, and every impossible combination attracts defensive if statements scattered through the codebase.

The worse part is that the if statements live in different services. The payment service trusts the payment columns, the shipping service trusts the inventory boolean, the refund service trusts the refund flag. Ask "what state is this order in right now?" and you get five answers instead of one, because each service's if statements rest on different assumptions.

There is a name for this condition: the implicit state machine. A machine genuinely exists, because the flow genuinely happens. It is simply not written down as a table, not gathered in one place, not made explicit. Implicit machines are hard to debug, incomplete to test, and fragile to any change in one feature. The discipline argued here is one move: make the implicit machine explicit, in one place, readable as a table.

## State, Event, Transition, Guard

An explicit state machine is fully described by four words, and each word carries a different responsibility. The moment the responsibilities split, the system starts to be readable.

A state is the answer to "where is it right now?" pending, paid, shipped. Only one is true at any moment. An order is in transit or it is not; it is not both. At any given instant, there is exactly one state.

An event is something that already happened. A payment was confirmed, a user canceled, a reviewer approved. Events do not write to the state directly. The system receives an event, and the receipt decides whether a transition fires.

A transition is the rule: in this state, given this event, under this condition, go there. Not every combination has a destination. A payment confirmation arriving at a completed order has nowhere to go, and the transition table only records the places you can go.

A guard is the condition checked before a transition executes. The table may say that paid can move to inTransit on a ship request, but if the guard "is inventory confirmed?" returns false, the move does not happen. A guard can block a transition or let it pass. The guard is the judgment.

Four questions, four answers. "Where is it now?" is answered by the state. "What happened?" by the event. "Is there a place to go?" by the transition. "Are the conditions met?" by the guard. A system that could not answer those questions now carries the answers inside its structure.

## Name States by What They Are Waiting For

A state name should answer exactly one question: what is this object waiting for right now? An order in pending waits for payment confirmation, so it is named awaitingPayment. An order that has received money waits for shipment, and paid names exactly that position: payment confirmed, awaiting dispatch. The name should reveal the wait.

The rule pays off when a new state tries to enter. Ask what that state is waiting for, and if the answer comes in two forms you have two states. Lumping payment-approval-waiting and admin-review-waiting into one processing leaves you blind when a bug parks an order somewhere, because you cannot tell which wait it is stuck in. Split it into awaitingPaymentApproval and awaitingReview, and the events that end each wait differ too: the provider's webhook moves only the first, the reviewer's click only the second. Naming the wait also names the exit.

How many states is a good number? For a small product, four to seven feels natural, and more than ten should raise suspicion. If you exceed ten, there are two suspects. Facts have snuck in as states, or two machines have tangled themselves into one column, and two small machines are easier to reason about than one large one.

Terminal states get their own care. They have no outgoing transitions, and once an object enters one it becomes read-only. The benefit arrives twice. The question "it was completed, why did it cancel?" stops existing, and every event that reaches a terminal state can be handled as one bucket: does not move.

The common failure of a bad name is that it can attach to anything, and processing is processing in every object at every position. Put the renames side by side.

| Bad name | Good name | Why it works |
|----------|-----------|--------------|
| processing | awaitingPayment | names the wait |
| active | paid | names the object and the position |
| done | completed | says what finished |
| failed | paymentFailed | says which failure |

## The Transition Table Is Data, and One Function Runs It

The single most important decision: the transition table is data. In the bad form, transitions live as scattered if statements, each pairing an event with a state by hand. When a requirement changes you must find every one of them, and there is no guarantee that "found them all" means anything. Fix the payment path and miss the shipping path, and two services process the same event into different results. The good form is a table plus one apply function: the table records, for each state, which event leads where, and the function does not judge; it executes. Judgment lives in data, execution lives in one function.

```python
TRANSITIONS = {
 "awaitingPayment": {"paymentConfirmed": "paid", "userCanceled": "canceled"},
 "paid": {"shipRequested": "inTransit", "refundRequested": "refundPending"},
 "inTransit": {"delivered": "completed"},
}
```

The order of checks inside apply is not arbitrary, because each check produces a different kind of rejection. Is the current state terminal? Does the table have a rule for this state and event? Does the guard pass? Does the write win the lock? Is the history row recorded in the same transaction? "Terminal", "no rule", and "guard false" are different bugs, and lumping them into one error makes the later debugging impossible.

Guards stay pure. A guard reads a context and returns a boolean. It does not write to the database, and it does not call an external API. A guard that waits two seconds on a network call makes transition timing nondeterministic, and waiting for something to become okay is not a guard's job. If checking inventory takes time, make "inventory confirmed" a separate event, and let the guard ask only about facts that already happened.

Concurrency is settled the same way. When two payment confirmations arrive at once, both read the same state and both compute the same next state. With optimistic locking, exactly one write succeeds, and the loser either retries or answers "already processed". Duplicate delivery from external systems is expected traffic, and one event_uid column in the history closes it: same input, same result.

## One Column Holds the State, One Row Holds Each Fact

Where does a finished state machine live? One principle covers it: the current position is a single column, and each fact that happened is a single row.

The orders table has one status column, and that column alone answers "where is this order right now?" No second column to cross-check, no guessing. Next to it sit the fact columns: paidAt says when payment was confirmed, shippedAt says when it went out, refundReason says why. Facts do not change. Once written, they stay. State changes, facts accumulate.

Inferring state from facts is a warning sign. The moment someone writes "if shippedAt is set, treat it as in transit", the bug is born: a delivered order that has shippedAt gets read as still in transit. Facts answer "when did it happen". They cannot answer "where is it now". Two questions, two columns.

The change itself is also recorded, one row per transition. From which state, on which event, at what time, by whom, to which state. That is the history table, and it is append-only. Once a row is written, it is never edited or deleted.

A mistake is corrected with a new event: a cancelReversed row, not an erasure of the cancel. Editing the history destroys the evidence of what actually happened. And the history's second duty is to record what did not move. A rejected event leaves a row that says "received, but stayed", and only with those rows can you answer "why did it not move?"

## When Tests, Debugging, and Extension Get Easy

An implicit machine is tested by code paths, so the test suite grows with the code, and "we covered everything" is a feeling rather than a fact. An explicit machine is tested by its table, and the table is finite. Six states and eight events mean forty-eight combinations, and the loop below walks every one of them. When the table changes, the tests grow with it automatically: a new state adds one row per event, a new event adds one row per state.

```python
for state in STATES:
 for event in EVENTS:
 result = apply(make_order(state), event, fake_ctx)
 expected = TRANSITIONS.get(state, {}).get(event)
 if expected is None:
 assert result.rejected
 else:
 assert result.accepted and result.next_state == expected
```

Testing the rejections matters as much as testing the moves. "The code did not crash" is not success. Success is "the illegal combination came back as a rejection with a reason". Terminal, no-rule, and guard-false rejections are different bugs, and if the tests do not name the reasons, the production investigation will not either. Invariants close the second gap: a transition test checks where each move lands, an invariant checks what must hold on every path, like "if completed, then completedAt exists". Invariants are worth running in production too, as a daily batch over every object, reporting only the broken ones.

The common production incident is a state that should not exist, a completed order with a refund in flight. With an implicit machine, investigating it is archaeology: grep every place that writes status, reconstruct the sequence from logs, lose the afternoon. With an explicit one, you read the history. One query in time order produces the timeline, and if there is a gap in the timeline, the gap is the bug. When an impossible state appears, ask first whether it is a path in the table. If the table contains it, the table is wrong, a design bug. If it does not, the code bypassed apply, an implementation bug. Two kinds, two fixes, and "add another if" is neither of them.

A new requirement lands: allow cancellation within 48 hours of dispatch. In an implicit machine you find every place that decides cancelability and hope you found them all. In an explicit one you add a cell, a guard, and a state, and the cost of the requirement is visible before you write code. The counter-example is the promotion code. It does not move the order, it adds a fact, one column, zero new cells. Asking "is this a state or a fact?" first is what keeps the table from bloating.

## The Minimum Three, and Where a Machine Does Not Fit

A state machine fits objects whose position is singular and countable: orders, subscriptions, documents, approvals. It does not fit everything. Undo and redo in an editor is not a position, it is a stack of actions. An object where several sub-processes advance at once, payment and inventory both in flight, wants one machine each and an explicit combination, because forcing them into one column multiplies the states. The test is simple: does one position explain the object? If you can read "the order is in transit and the refund is in flight" as two machines, do not merge them.

When the deadline is real and nothing can be refactored before launch, do the minimum three. They finish in a day.

First, draw one table. The states and events of one object you ship today, on a single sheet of paper. The drawing reveals the empty cells, and an empty cell is not unfinished work. It is a specification: this must not happen.

Second, gather every direct write of status into one place. You do not need the full apply function yet. You need the if statements that assign status to stop being scattered, so that transitions have a home. Turning the table into data is the next job.

Third, create the history table. Append-only, with from, event, to, and time. With just those three in place, "how did it get here?" becomes a query instead of an excavation, and most of the debugging value comes from here.

After the three, the next requirement is no longer "add another if" but "change one cell in the table", and that one-sentence difference is the whole discipline. If you want to go deeper, the ebook *The State Machine Discipline* carries all four chapters as a PDF, from the state inventory through guards, concurrency, and history operations.

## References

The four terms of state, event, transition, and guard, the transition table, the append-only history, and the optimistic concurrency handling in this post can be checked against the following.

- [Finite-state machine (Wikipedia)](https://en.wikipedia.org/wiki/Finite-state_machine)
- [State pattern (Wikipedia)](https://en.wikipedia.org/wiki/State_pattern)
- [State diagram (Wikipedia)](https://en.wikipedia.org/wiki/State_diagram)
- [Event Sourcing (Martin Fowler)](https://martinfowler.com/eaaDev/EventSourcing.html)
- [Optimistic concurrency control (Wikipedia)](https://en.wikipedia.org/wiki/Optimistic_concurrency_control)
