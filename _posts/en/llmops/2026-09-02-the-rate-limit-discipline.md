---
title: "The Load That Kills Your Service Is Your Own Retry Storm"
excerpt: "When traffic surges it is easy to assume the service dies from the incoming load, but the real cause is usually the second wave the system calls on itself, the retry storm. This piece lays out the exact loop overload runs through, then shows how to break it at three points with numbers: the server rate limit, the client backoff, and the LLM API budget. It argues why deliberately slowing down and refusing is the whole of overload defense."
seo_title: "Why Retry Storms, Not Traffic, Take Services Down, and How Rate Limits, Backoff, and LLM Budgets Stop Them"
seo_description: "Under overload a service usually dies from the load it calls on itself, not the traffic sent to it. How a token bucket with 429, exponential backoff with jitter, and LLM API budget enforcement break the cascade failure loop."
date: 2026-09-02
last_modified_at: 2026-09-02
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - rate-limiting
  - backpressure
  - retry-storm
  - llm-api-cost
  - token-bucket
  - load-shedding
  - cascade-failure
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/the-rate-limit-discipline/"
ebook: /assets/ebooks/the-rate-limit-discipline.pdf
ebook_title: "The Rate Limit Discipline"
ebook_pages: 34
---

This is for the solo developer running a production service that calls an LLM API. If traffic and cost can spike at the same time, this piece gives you the minimum discipline that keeps the service alive. The conclusion up front: under overload, what kills a service is rarely the incoming traffic. It is the second wave of load that the system calls on itself, the retry storm. And the only way to stop that storm is to say, before things collapse, not now, come back a little later.

Most developers assume they die from a lack of capacity. So when traffic arrives they add servers, add cache, add cores. That instinct is usually right. A retry storm, though, is a different animal. This piece first lays out the exact loop that overload runs through, then shows how to break that loop at three points: the server, the client, and the LLM API.

By the end you will be able to decide for yourself how to set a token bucket limit, why you add jitter to a retry, and why an LLM budget must be enforced in the code right before the call instead of on a dashboard. All three are the same act, setting a limit before the incident.

![Illustration of the core idea of The Load That Kills Your Service Is Your Own Retry Storm](/assets/images/the-rate-limit-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## The Loop That Kills a Service: The Second Wave of Retries

Write the progression out in order. A little more traffic than the capacity arrives. Some requests begin to wait, and the time to handle one request grows. Because handling is slower, more requests pile up at the same time. Clients and load balancers wait for an answer and finally time out. And the timeout becomes a retry. Traffic rises again. That rise makes the handling slower still, and the loop returns to the wait.

The fatal step is the retry. A single failure comes back as a second wave of traffic through the retry. A system usually dies not from the load that was sent to it but from the load it called on itself. This loop is a cascade failure. Any service without a ceiling ends here, regardless of scale or stack. The cause of death was never that traffic arrived too fast. It was that nowhere in the system was there a thing that could say not now.

Put numbers on it. Suppose 1,000 clients are calling a provider that is already wobbling, and at the first moment 500 of them fail. If all 500 retry at the same instant, the provider takes the remaining 500 healthy requests plus 500 retries in the same interval. If it fails again, the next interval carries 1,000 retries. The load doubles every round. The original incident was half the clients failed. The incident the clients created is all of them failed.

What the provider needs is time. And the side that can give it time is the client that backs off. So overload defense is not handling faster. It is deliberately slowing some requests down or refusing them. If you neither slow down nor refuse, delay becomes retry, retry becomes larger delay, and delay becomes retry again. The rest of this piece breaks that loop at three points.

## Scaling Up Cannot Win This Loop

The instinct is always to add more servers. And most of the time that is right. If capacity is genuinely short, scaling is the answer. But a retry storm is exponential, not linear. If two times, four times, eight times the normal load piles up every round, no rate of adding instances can chase that curve. Scaling is linear. The storm is exponential.

For a service that calls an LLM API the problem is one size larger. The capacity of an LLM is not CPU or memory. It is money. You are billed per token, the response eats several seconds, and the length is decided by the model. Doubling the instances does not lower the price of a single token. A feature that handled a hundred requests a day can burn a month of budget in an hour on the day a user pastes in a long document.

So the goal of overload defense is not to maximize throughput. The goal is to fix in advance the maximum load the system can take without collapsing, and to politely refuse the requests that want to cross it. If it does not collapse, there is no retry and no second wave. A system that holds up recovers on its own, slowly. A system that has fallen over must put out the storm it started, with its own hands.

Seen this way, rate limiting is not a feature. It is a safety device. It does not let you ride the peak further. It keeps the peak from dragging the whole system down with it.

## The Server's Muscle: The Token Bucket and 429

A server's judgment of now you may and now you may not is only as exact as its algorithm. The most intuitive is the fixed window. Count requests in one minute and send 429 past a hundred. Reset the counter to zero at the start of each minute. The limit is one number, the counter is one. The problem is at the boundary.

A well-behaved client that sends a hundred in the last second of one minute can send a hundred in the first second of the next. Two hundred in two seconds. The per-minute average is inside the limit, but the momentary peak is twice the limit and it passes through. If the database cannot survive that peak, the boundary problem is 11 p.m. on a Saturday night. The fixed window is enough for a coarse limit on a low-traffic service.

To fix the boundary you must look back the last sixty seconds from now. Stamp every request with a time and count how many fall inside the window that ends now. The result is exact. The two-hundred boundary spike cannot happen anywhere. But there is a price. You must keep the timestamps of recent requests until they age out of the window. On a busy endpoint that is thousands of entries per user, and the limit itself becomes a thing that eats resources. For a solo developer the sliding window is a tool you reach for only when the token bucket stops being enough.

The token bucket is the worker in most production services. It runs on two numbers. rate is how many tokens fill the bucket per second, the sustainable speed. burst is the size of the bucket, how many you allow in a single instant. A request takes one token, and when the bucket is empty you send 429. Because rate fixes the average load and burst fixes the allowed momentary peak, there is neither the fixed window's boundary leak nor the sliding window's storage burden.

| Approach | Boundary burst | Storage cost | Fit for a solo service |
| --- | --- | --- | --- |
| Fixed window | Twice the peak passes | One counter | Enough for low traffic |
| Sliding window | None | A timestamp per request | Only when forced |
| Token bucket | Controlled by burst | Two numbers | The default |

Set the three limits side by side and the choice shows itself. The fixed window is simple but leaks twice the peak at the boundary. The sliding window is exact but stores a timestamp per request. The token bucket lets you set the momentary peak directly with burst and runs on two numbers, so it is the default.

When you send 429, do not forget two things. Attach a Retry-After header so the client knows how long to wait. And make it clear, in code and in logs, that the 429 means the limit was reached, not that the server died. A 429 emitted by a dead server is indistinguishable from a timeout, and the client raises the storm again. Only a 429 sent deliberately by a live server gives the client the reason to start backing off.

## The Client's Muscle: Backoff and Jitter

Sending 429 from the server is half the story. The other half is the client that receives it. When my service calls a payments provider, an LLM, or a database, I am already a client standing behind somebody's rate limit. The most common retry code in the field is two lines: an exception, and immediately call again. That code, once the provider starts to wobble, fails every request at almost the same instant and retries every client at almost the same instant.

For a retry to be safe, one of two conditions must break. The retry must be well after the failure, or it must be offset in time from the other clients. Exponential backoff handles the first, jitter handles the second. Exponential backoff stretches the retry interval to one, two, four, eight seconds, buying the provider time to recover. Jitter mixes a random amount into that interval so that thousands of clients cannot all retry at the same instant.

Look at the same 1,000-client example again. With exponential backoff and jitter, when 500 fail at first the retries do not pile into one instant. They spread out. The provider takes the load back in a shape where the healthy requests and the retries do not overlap. The load does not double. It falls, slowly, at the pace of recovery. Simultaneous retries with no jitter grow the load twice every round, which is why recovery takes minutes.

Pair this with load shedding, the art of throwing requests away when it is crowded. Not every request gets a retry. A low-priority request is refused without a retry, and only the critical ones ride the backoff. In a service that calls an LLM, a non-critical call like a summary is dropped first under overload. A dropped request comes back to the client as a 429 and returns later through the backoff. Deferring a moment is always better than collapsing the whole thing.

## The LLM API: The Budget Is Control, Not Monitoring

The shape of the risk changes once a service calls an LLM. An ordinary API call has a ceiling on its cost. A few milliseconds of compute, a fixed price. An LLM call is billed per token, the response eats seconds, and the length is the model's decision. So overload defense here must stop traffic and cost at the same time. You are protecting the invoice and your service, both.

The most common first mistake is to treat the LLM cost as a monitoring problem. A dashboard that shows the spend going up is useful after the fact. It is useless while you sleep. While the dashboard says yesterday you spent three hundred dollars, the service is burning tomorrow's budget tonight. What is visible is already in the past.

The working model is that the budget is enforced and the spend has a ceiling. There are three budgets. The daily budget is the absolute ceiling you can lose in a day. The per-request budget is the maximum a single call may burn, the input fixed by the context length, the output fixed by the maximum tokens. The per-user budget is the ceiling one account may burn in a day. What breaks me is usually one big user, and a per-user ceiling turns that one animal into an account with a limit. All three are enforced on the server, right before the call.

When the daily budget is spent, a non-critical LLM feature is replaced with a polite sentence. The AI answer is full for today, please try again tomorrow. That sentence is better than the invoice and better than silence. It is a clear refusal that needs no retry, not a timeout that calls one. An exhausted LLM budget is also a form of overload, and the response is the same. Do not collapse. Refuse on purpose.

Do one calculation. The prices are examples. Three dollars per million input tokens, fifteen dollars per million output tokens. [Example prices. Substitute the table of the model you actually use.] Take a question and answer call at two thousand input tokens and three hundred output tokens, and one call works out to about 0.0105 dollars. [Estimate] A hundred thousand calls a day is about 1,050 dollars. Those numbers are the basis for the per-request and per-user budgets. Set the per-call ceiling at 0.1 dollars and a user who pastes in a hundred thousand tokens cannot send an invoice beyond that.

## Overload Defense Is a Discipline, Not a Feature

Look at the three controls again and the common point shows. The server's rate limit, the client's backoff and load shedding, the LLM API's budget enforcement. All of them are fixing a limit before the incident. All of them are building, in advance, a thing that can say not now, come back a little later. That sentence does not appear on its own when the peak arrives. You put it in on purpose, at design time.

What running a production service as a solo developer taught me is that keeping a service alive under overload is the hardest and the most expensive thing you do. The energy spent putting out a retry storm after the collapse is many times the energy spent setting a limit before it. And in a service that calls an LLM, that price comes back as an invoice, not as traffic.

So the conclusion. When traffic surges, do not try to handle it faster. Slow down on purpose. Refuse on purpose. The server fixes the number at the door with a token bucket. The client steps back with exponential backoff and jitter. The LLM budget is a ceiling enforced right before the call. With just those three, the system stops dying from the load it called on itself. The technology that does not collapse is not the technology that scales. It is the technology that says not now.

For the token bucket implementation, where the budget enforcement goes, and the load-shedding priority table, the 34-page ebook on this subject has the detail. With the PDF's implementation notes, moving the three controls of this piece into your service's code is an hour or two of work. [Estimate]
