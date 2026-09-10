---
title: "Error Budgets Turn 'Should I Ship Tonight' Into Arithmetic"
excerpt: "Make it more stable' has no stopping point. An error budget ends that by writing the stability promise as a number, so the decision to ship or hold stops being a feeling and becomes arithmetic. This post walks solo developers through picking the user-facing SLI, sizing the budget in minutes, reading burn rate, and writing a one-page policy that decides for you at 2 a.m."
seo_title: "Error Budgets for Solo Developers: SLOs, Burn Rate, and a One-Page Policy"
seo_description: "Turn 'should I ship tonight' into arithmetic: user-facing SLIs, a real SLO, 43 minutes of error budget, burn rate, and the one-page policy you follow at 2 a.m."
date: 2026-09-11
last_modified_at: 2026-09-11
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - error-budget
  - slo
  - sli
  - burn-rate
  - sre
  - production-ops
  - solo-developer
  - reliability
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-error-budget/"
ebook: /assets/ebooks/the-error-budget.pdf
ebook_title: "The Error Budget"
ebook_pages: 31
---

This post is for solo developers who run production alone; read it to the end and you will hold a set of numbers that moves the 'ship it tonight or watch it' question out of mood and guesswork. The answer, stated first: that set of numbers is the error budget.

'Make it more stable' is a goal with no stopping point. Fix one thing and two more show up; fix two and three more appear. The problem is never effort. The problem is that 'how stable is stable enough' has no answer, and without an answer every choice is a guess. Guesses get expensive at 2 a.m.

This essay makes one claim and argues it to the end. The moment you write the promise as a number, stability stops being an endless goal and becomes a finite limit you can manage, and operational judgment stops being a mood and becomes arithmetic. The number you promise is the SLO, the headroom left over is the error budget, and the speed at which you spend it is the burn rate.

![Illustration of the core idea of Error Budgets Turn 'Should I Ship Tonight' Into Arithmetic](/assets/images/the-error-budget-hero.webp)
*A visual metaphor for the article's key idea.*

## A goal with no stopping point

Stability has an unusual property: no matter how well you do it, 'more stable' always seems possible, so the instruction 'make it more stable' feels bottomless. For a solo developer the instruction-giver is usually themselves, so the bottomlessness cannot be handed to anyone else.

The framing I want to argue is different. The situation feels hopeless not because stability is infinite, but because 'sufficient stability' has never been defined. Without a definition you re-decide every night. Tonight, do you ship the new feature, or spend the evening on monitoring? Between those two options there is no number, hence no evidence.

A decision without evidence is a guess, and a wrong guess costs you at 2 a.m.: you discover the outage in progress, spend the night rolling back, or both. The error budget removes that cost-of-guessing structure. The method is simple: write one line, 'this service works for the user 99.9 percent of the time, measured over a month.'

That line is not marketing copy; it is a line drawn around the system that decides where the next hour goes and where it does not. Only when the line exists is effort inside it stabilization and effort outside it features. The rest of this essay argues the order in which the line is drawn and how the numbers it creates do the judging for you.

Without the line there are only two strategies: ship fast and fix when it breaks, or stabilize forever and ship nothing. Neither reduces the nightly worry. The error budget adds a third: draw the line, stabilize up to it, then compete on features inside it. Once the direction is fixed, the nights get shorter.

## Measure the user, not the machine

Before any number, there is an order: decide what the user feels, choose the number that measures it, then draw the line. The order cannot be reversed. Draw the line first and you choose whichever number is easiest to measure, and the contract slides from the user's experience toward the state of the servers.

The reason the user is the object of measurement is simple. A service can look perfectly healthy by every internal metric and still be a failure if the user cannot save their note. Conversely, a wall of server warnings is only a problem for my peace of mind if the user feels nothing. So the SLI, the service level indicator, has to measure what the user experiences: the percentage of requests that returned a 200 status code.

'The percentage of servers whose CPU stays under 80 percent' is also a number. But it is not a contract; it is internal reassurance. The first is a promise to the user. The second is a sedative I take alone. Substitute one for the other and the SLO formally holds at 99.9 percent while in substance it guarantees nothing.

Picking the core SLI is practical. Temporarily pretend the servers do not exist, and write down what a user actually does with the service. For a notes app: open, write, save. For a photo sharing service: upload, view. For an API: a partner calls it and gets a correct answer. Choose the moment whose failure is most costly; it becomes the candidate for the core SLI.

For the notes app, the death moment is a failed save. A slightly slow open is an annoyance, not a death. So the core SLI becomes the percentage of save requests that succeed, not overall response latency. Measure everything equally and the signal drowns in noise. Write one line under each action, 'if this fails, what does the user lose,' and the list usually comes out short. A short contract is a feature, not a defect.

Measurement numbers come in roughly four kinds. Availability: did it work. Latency: how fast did it work. Correctness: was the answer right. Freshness: how new is the data. Most services start from availability, but the weight shifts with the service's nature. A search request can succeed and still be a failure if the answer is wrong. A news feed can be correct and still be a failure if it is a day old. You may carry two or three core SLIs, but each must name the loss it covers. If it cannot, it is an auxiliary metric, and a contract should never rest on auxiliary metrics.

## Forty-three minutes

Once the SLO is drawn you hold a monthly allowance of failure. An SLO of 99.9 percent over a one-month window permits 0.1 percent of the month. Take the month as 30 days and the allowance converts to roughly 43 minutes. That 43 minutes is the error budget.

The first effect of the number is that stability becomes a size you can feel. 'More stable' was infinity. 'Keep this month's failures inside 43 minutes' is finite. A finite limit can be measured, compared, and planned against. Guesswork stops here, at least once.

The second effect is unit conversion. If the SLI is per-request, the budget can be written in counts as well as time. A month of 100,000 requests at 99.9 percent allows 100 failures: about 3 a day, about 23 a week. When the dashboard says '12 errors today,' it is no longer a bare number; it is the sentence 'I spent four days of budget in one day.'

One point deserves to be stated exactly. This number is not a prediction of how much you will fail; it is a limit on how much you may fail. An expectation and a boundary are not the same thing. Nobody should treat the budget as permission to fail a little. The budget does not permit failure. It is the device that lets you notice the moment failure crosses the limit.

Once it reads as a limit, behavior changes. Inside the 43 minutes, hands off. Outside it, look for the cause. Outside it in a streak, stop shipping. The same 'there was an error' situation is a work item when the budget has room and an incident when it does not. That distinction answers half of the 2 a.m. 'is this serious' question before the first coffee is finished.

## Burn rate is severity right now

A monthly total cannot answer the question you face every day: not 'is the month on track' but 'is the failure happening right now serious.' A month-long budget is slow; failures clustered mid-month still look fine on the aggregate. The metric that fixes that slowness is the burn rate.

Burn rate writes the drain speed as a multiple. The baseline is 1x: at 1x the budget reaches exactly zero on the last day of the month, not an emergency but a red month. At 10x the story changes completely. The budget is exhausted in about 3 days, which is no longer a monthly problem but the problem that the service is breaking right now.

A fuel-gauge analogy helps. A 1x burn is a long drive with the needle drifting down; it looks fine. A 10x burn is a signal that the tank is leaking: the gauge still reads half, but at the leak rate the car dies today. The error budget works the same way: the remaining balance is not a present state but a function of the time left.

Back to numbers: 1x spends about one of those 43 minutes a day; 10x spends about 14 a day. The same error fits this month at the first pace but blows the week at the second. Burn rate answers exactly one question: when does it break.

Practically, you read two windows together. A short window, the last few hours, gives the fast signal: a high burn there means the thing happening now is big. A long window, the month, is the check: does the fast signal actually dent the budget? When both agree, it is an incident. When they disagree, the safe move is to re-examine both, not to pick a side.

The second value of burn rate is the speed of judgment. 'This error level is about normal' is a feeling whose evidence changes every time and whose memory is biased. Burn rate always produces the same number the same way: 7x today, 1.2x yesterday. Feelings wobble; the number does not. Much of the cost of running production is paid in those wobbles.

## The arithmetic of shipping and stopping

Once the numbers are chosen and the alerts exist, what remains is discipline: when to ship and when to stop. Writing that discipline down as a one-page document is the error budget policy. 'Use your error budget well' is not a policy; it is a wish. A policy is a sentence that produces a decision without a meeting.

The shape is this: if the month's error budget usage crosses half, freeze releases until the budget recovers. The value half is not a verified constant; it is an estimate, the place where you decide how much risk this service, and you, can carry. What matters is less the value than the fact that the 'if' is now a number.

Written as numbers, judgment is no longer mood. Monday, the budget is 80 percent full: ship. Thursday, an incident burns it down to 20 percent: freeze. Friday, the feature is fully ready: still 20 percent, so do not ship. This is arithmetic. Shipping at 20 percent means betting the rest of the month on a single failure.

The freeze is not only about preventing incidents; it is a device that names the decision not to ship. Without a name, the decision requires fresh courage every time, and where courage is needed repeatedly, eventually one night you just ship. With a name, the decision is one line of policy, and executing it requires no fresh courage. The expensive thing in production is not the incident; it is the repetition of unnamed decisions.

Exceptions belong in the same document. A policy without exceptions is broken by force. Security patches and data-corruption fixes must ship even while the budget is frozen. If the exception is not written down, you become the person breaking your own policy, and a policy broken once loses its authority. So the exception goes into the policy: security patches and data-corruption fixes proceed regardless of the freeze.

The freeze is not permanent: with no incidents the budget returns at the 1x pace, a little over a minute a day. A freeze is a wait for recovery, not a punishment, and the policy stays liveable only if the wait has a known length.

## A committee of one

For a solo developer the policy must be simpler still: there is no committee to enforce it. In an organization, the person who breaks the policy shares the consequences with others. Alone, the person who pushes and the person who pays are the same person. So the policy has to be short enough to read in ten seconds.

The content is one line each. A ship threshold: if the budget is above this, ship freely. A freeze threshold: if it is below this, stop shipping. A freeze behavior: what you do first when frozen, roll back, flip a feature flag off, or simply wait. Anything longer than those three lines will not be read. Anyone here means you.

The policy document is not for normal times; it is for the panic moment. At 2 a.m., with the service down and judgment at half strength, two pages of principles help nobody. Three lines help, because they are sentences the calm you already agreed to. In panic, the job is not to make a new decision; it is to re-execute an old one.

To close the chain: the error budget turns stability from an endless goal into a finite limit. The limit is set by an SLI that names the user's experience, converted into a size you can feel (43 minutes), read at the speed of burn rate, and fixed into a policy sentence that makes ship-or-stop arithmetic instead of mood.

Every night's worry about stability converges on the same question: is this enough? With an error budget you can read that question differently: does it fit inside the budget? When the question changes, the night changes, and the list of what you are allowed to ship the next morning changes with it. If you want the argument carried further, chapter by chapter, the companion ebook, The Error Budget, extends it across 31 pages.
