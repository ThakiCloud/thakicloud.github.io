---
title: "Overrun Is the Default, Not the Exception"
excerpt: "Your estimates come in 1.5 to 2 times low not because you are dishonest or under-skilled, but because of how the number is produced. This piece argues the four-step process end to end: outside view, named buffers, checkpoint re-estimation, and a personal estimation log, which you can run on your very next quote."
seo_title: "Project Estimation in Practice: Why Estimates Come in Low and the Four-Step Fix"
seo_description: "Why low estimates are a process problem rather than an honesty problem, and the four-step discipline to fix them: reference class, named buffers, checkpoint re-estimation, and an estimation log that grows into your own correction factor."
date: 2026-08-31
last_modified_at: 2026-08-31
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - project-estimation
  - planning-fallacy
  - reference-class
  - buffers
  - re-estimation
  - freelancing
  - time-management
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-estimation-discipline/"
ebook: /assets/ebooks/the-estimation-discipline.pdf
ebook_title: "The Estimation Discipline"
ebook_pages: 31
---

If you quote time for solo dev work or a startup, and the actual keeps landing 1.5 to 2 times the quote, this piece is for you. You get a four-step process for your very next estimate. The conclusion first: your estimates come in low not from dishonesty or under-skill, but because the process that produces the number counts only the work, never the environment it happens in.

A restaurant app gets mobile ordering. Design one week, build two, testing one: four weeks, an honest plan. It actually took nine [estimate]. Three weeks waiting on the payment processor's approval, two while the owner reworked the menu twice, two untangling a bug in the existing reservation system. None of the three fit the shape of a plan.

The fix is four steps: look from the outside, give buffers names, re-estimate at checkpoints, build your own factor from a log. Overrun, the default, starts moving with the next estimate.

![Illustration of the core idea of Overrun Is the Default, Not the Exception](/assets/images/the-estimation-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## The Plan Only Counts the Work

When you plan, one path runs through your head: which features go in, which tech, which order. The number that path produces is the estimate, and the lens that produces it is the inside view.

The inside view holds only the obstacles you thought of. What surfaced in week four was waiting on approvals, the client changing the bar, an unplanned bug; only things you can box on a Gantt chart get to be called work.

The MVP went the same way. Prototype two weeks, backend two, integration and testing two: a six-week plan that shipped four months later [estimate]. Recruiting user interviews ate three weeks, the scope grew from booking to booking plus seat selection and reviews, and one core developer moved teams. The plan was not a lie. It simply contained only the work, never the environment.

Overrun does not happen in one place. A four-day approval wait in week two pushes week four, and week four pushes week five. No buffer in week one, and you are on your knees in week four.

The bigger loss is not the weeks. A five-million-won site quoted at three that finished in six halves the hourly rate [estimate]. The first impression the client formed was that this person cannot be trusted on time; skill and time management are rated separately, and the latter's reputation sets the price of the next quote.

## Knowing Does Not Stop It

In a famous experiment, students estimated how many days their theses would take; results were consistently short. A group told the previous term's average still underestimated, knowing the outside number but believing this time was different.

Projects that hit the deadline stay vivid; three-weeks-turned-nine get filed under the client was difficult. The tech, client, and scope are all different, so the brain does not think past statistics apply this time. Selective memory and the illusion of uniqueness produce the same result.

The stronger the confidence, the lower the number. The moment you explain the plan to a client, the brain is already selling it. Belief shortens the path, so the estimate you are most sure of is often the least accurate.

Experience does not fix it either. A ten-year developer knows how long their own coding takes. The part experience does not grow is outside the project: approval times, review cycles, vendor release schedules. Skill does not make those faster; only data does, and most people never collect it.

Low estimates also win the work: in a bid, three beats five. The cost of quoting low looks small up front; the cost of overrunning is large. Over ten deals the arithmetic flips. Anchoring stacks on top. The first number spoken becomes the reference point, and the client schedules marketing, budget, and team around it. The moment you say four weeks, four weeks becomes their operational fact.

## The Other Question: How Did Similar Projects End

The outside view asks a different question: how do projects like this usually end. List similar past cases' actual durations and quote from the top of that distribution. That set of cases is the reference class.

Define the class on scale, domain, team, and environment. New feature on a three-year-old service, three to six weeks, one-person team, third-party API included: that one line is the class. Seventy percent overlap is enough, the rest is correction. Define it before you look at your own estimate; cases collected after the number is out only support the number.

Sources have an order: your own records first, then colleagues, the client's past, industry data. A colleague's answer is usually the actual, because colleagues are not asked for quotes. The client's past is data too: how long the last similar feature took reveals the client's expectation, and three weeks is enough is the floor of their class. Industry data is self-reported, so an average of six is best used as a signal that it will probably exceed six.

Say eight cases took three, four, four, six, eight, nine, eleven, fourteen weeks. The temptation is the minimum or the median, and both are wrong: overrun cases are possible scenarios to include, not outliers to filter out. Quote from around the 75th percentile, between nine and eleven. The percentile question is what do you pay if you overshoot. An internal tool: median. A contract with a delay penalty: eleven, from the same data. The cost changed, not the data.

With no cases, widen the class and make the correction explicit. If the delivery app's subscription feature class is empty, widen to subscription payments you have built, then to any feature with payment integration. 75th percentile at 15 weeks, scope 60 percent smaller: 15 times 0.6 is about nine [estimate]. Write the correction as a sentence: scope is 60 percent of the class average, so corrected by 60 percent. Then the client can ask and you can answer.

The inside view can win only in limited cases. The client is cooperative, so it will be faster: test that thought instead of filtering it. Remove cooperative clients from the class and the remaining cases are likely still scattered from four to fourteen weeks. Cooperative is baseline. Real differences are stated in numbers: scope 40 percent smaller than the class average, or two years on this library. This time I am serious does not move the number. Write the class next to the estimate: nine weeks, basis, 75th percentile of eight cases; that line keeps the number through the first negotiation.

## Buffers Need Names

A buffer is an explicit cost attached to a risk you cannot calculate precisely. A lie hides inside the number; a buffer sits next to it. Base six weeks, buffer three, total nine is a different sentence than nine. The client can understand the composition and negotiate; if they ask to cut the buffer to two, you know which risk you are absorbing. Hidden padding survives only as distrust.

Names matter too. Two weeks for the payment processor approval is a buffer; two weeks in case something happens is not. A buffer without a name is padding, spent on the first unexpected event and gone. A named buffer is spent against the risk it was made for, which is why it lasts.

The criterion is uncertainty. Design: 10 percent or none. Core development: 20 to 30 percent. External service integration: 50 percent or more. The client's review cycle: 100 percent or more. The review cycle is the biggest hidden drainer: you send a version, the client goes silent for a week, returns with ten change requests, two of which are what we meant from the start.

Five tasks in practice:

| Task | Typical | Fastest | Slowest | Buffer |
|---|---|---|---|---|
| Design | 1 wk | 1 wk | 2 wk | none |
| Core development | 2 wk | 1.5 wk | 3 wk | 3 days |
| External service integration | 1.5 wk | 1 wk | 3 wk | 1.5 wk |
| Internal testing | 0.5 wk | 0.5 wk | 1 wk | 2 days |
| Two client review rounds | 1 wk | 1 wk | 2.5 wk | 1 wk |

The typicals sum to a six-week base, buffers to three, quote nine [estimate]. Two and a half of the three weeks sit in integration and review, the tasks with wide spreads and no control. Write the slowest number from the slowest that actually happened: four weeks for integration because the last three actually took four.

The buffer is yours. When the client asks to cut a week, silently cutting it is not the professional move: cutting buffer removes risk. The answer is a menu. Cut the scope and save two weeks, cut the review buffer to one and save one, or fix four weeks and bill the overrun hourly. A discount means you absorb the risk; delegation means the client does. One line, the review buffer of one week is delegated to you, prevents the dispute three months later.

## 80 Percent Progress Is Not the Remaining 20

The biggest enemy of re-estimation is the feeling of almost done. At 80 percent complete, the brain concludes the remaining 20 percent; it does not work that way. The first 80 percent was the planned part; the last 20 percent is the unplanned part: integration, edge cases, seasoning requests, bugs that show up only in production. The buffer is spent in exactly this last 20 percent.

Re-estimation asks what work remains and how long each piece takes. Rebuild the remaining work as a fresh list: the old one is full of almost done items, the most expensive, because verification remains, and verification is unplanned work. Outside-view each piece, add buffers, and the sum is the new estimate.

The new estimate is often larger than the time left. A nine-week quote with six weeks gone, remaining work at five, is eleven total. Two choices: move the deadline, or cut the scope. Both are legal; the illegal one is changing nothing and working harder, which burns the buffer and delivers late without even knowing it is late.

Silence is the priciest. Knowing the new estimate is worse and keeping work going without saying it: a week, two weeks of silence. Then, on delivery day, it will be a little late, and in that moment the client loses all trust. People are surprised by a delay told about early and angry at one discovered on delivery day; a week of silence costs ten times a week of being reported.

Checkpoints break that silence by institution. Set them when the estimate is made: a nine-week project has three, six, nine. Re-estimate even when the new number equals the old one. In week six, rebuild the remaining work: integration verification two weeks, internal testing one, review two. Five weeks against three left. The report is three lines: from week six it will take five more; the cause is the vendor staging delay and three changes from the last review; extend the deadline by two, or move the second review post-launch and ship a first version on the original date. The client picks the second; five minutes and three lines avoided the delivery-day confrontation.

Fixed-deadline projects invert. Fix the time first, subtract the total buffer, fit the scope into what remains. Cutting the buffer is the worst temptation: the calendar cannot be negotiated, only the scope. Ship the core on the date; move the rest to the next phase.

## Your Own Number Comes From the Log

The core asset is your own actual data; the cheapest way to collect it is one log. Project name, quote date, quote including buffers, actual duration, reference class, reason for the deviation. Create the line at the estimate; fill in actual and reason at the end. The reason can be one line: the processor approval took two weeks long.

Record what you actually said: if your head said nine weeks and your mouth said six, write six; an ideal-you log is abandoned within a month. Record the small ones too, a two-day job, a one-hour quote: small cases have small variance and accumulate fast.

After 10 to 20 entries the pattern shows. I always under-quote integrations; review cycles are always 1.5x. Sum twelve entries: 78 quoted weeks against 179 actual; 179 over 78 is about 2.3, your personal correction factor [estimate]. Use it as a sanity check, and to tell whether a class distribution is of actuals or quotes. A four-week base times 2.3 should be nine; quoting six needs a reason. Recompute every ten entries, and 2.3 moves to 1.7, then 1.3. The factor going down is evidence the system is working.

The goal is consistency on the slightly high side, because the cost of being low is the large one. The 75th percentile of the class plus 10 to 20 percent slack is a good starting point [estimate]. Consistently slightly-high quotes have an effect: the client starts to believe the number; if that person says six weeks, it will be six. That trust is capital. Slightly must not become largely: quotes two times high lose the work. The end state is high within 5 percent.

How long will it take: a range with conditions, never a single number. Four to seven weeks, two review rounds included; if the payment integration goes faster, the lower end. A client who hears a single number assumes certainty and plans on it. The condition is information. Certainty takes the top; speed takes the bottom with the risk. One thing to avoid: forcing a number onto an undefined scope. The inclusions are not settled, so I cannot give a number now. An overrun costs more than a lost deal.

Today's task is one: log your most recent finished project. Quote, actual, reason. Three minutes. The system starts from that line. The next quote walks the four steps, the buffers have names, the checkpoints are in the calendar, and the actual fills the next line. After ten lines you have your own correction factor. Estimation skill is the record of a repeated process.

For the deeper version of this argument, the ebook The Estimation Discipline expands it: percentile choice, buffer practice, pre-mortems, and the negotiation menu, in 31 pages.

## References

- The planning fallacy: [Buehler, Griffin, and Ross (1992) overview](https://en.wikipedia.org/wiki/Planning_fallacy)
- Reference class forecasting: [overview](https://en.wikipedia.org/wiki/Reference_class_forecasting)
- Anchoring: [overview](https://en.wikipedia.org/wiki/Anchoring_(cognitive))
