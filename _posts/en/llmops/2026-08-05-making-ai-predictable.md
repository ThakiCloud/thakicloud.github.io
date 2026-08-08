---
title: "You Cannot Control What an LLM Outputs, But You Can Control the System Around It"
excerpt: "Send the same prompt ten times and you can get ten different answers. Engineers who try to fix this by writing better prompts usually hit a wall. The ones who ship reliable LLM systems in production stop trying to predict the output and start designing the boundary the output has to cross."
seo_title: "LLM Production Reliability: Control the System Boundary, Not the Output"
seo_description: "Why does an LLM give a different answer to the same input? This piece walks through the root causes of non-determinism, prompt sensitivity, and hallucination, then explains how structured output contracts, failure-classified retries, and observability turn a probabilistic component into a reliable production system."
date: 2026-08-05
last_modified_at: 2026-08-05
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - llmops
  - llm-reliability
  - structured-output
  - production-ai
  - observability
  - prompt-engineering
  - ai-engineering
  - agentops
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/making-ai-predictable/"
ebook: /assets/ebooks/making-ai-predictable.pdf
ebook_title: "Making AI Predictable"
ebook_pages: 15
---

If you have ever put a large language model behind an API and shipped it as part of a real product, you have probably lived through this moment. A prompt that worked flawlessly yesterday returns a differently shaped answer today. You did not touch a single line of code. Most teams respond to this by tightening the prompt. They add more instructions, more examples, and repeat "respond only in JSON" a few more times for good measure.

That instinct is not wrong, but it is not enough. An LLM is, underneath everything, a machine that selects the next token according to a probability distribution, and no amount of prompt polishing removes that fact. Even the most carefully worded prompt cannot fully eliminate the model's internal non-determinism, its oversensitivity to small changes in input, or its tendency to invent plausible sounding facts that are not true. This piece is about what to do once you accept that reality. The core argument is simple: the real engineering work of putting an LLM into production is not predicting its output. It is designing the boundary that unpredictable output has to pass through before it can affect anything else.

![Illustration of the core idea of You Cannot Control What an LLM Outputs, But You Can Control the System Around It](/assets/images/making-ai-predictable-hero.png)
*A visual metaphor for the article's key idea.*

## Why the Same Question Gets a Different Answer

It helps to start by naming the cause precisely, because most engineers misdiagnose it. A common assumption is that non-determinism is purely a temperature setting problem. Set temperature to zero, the thinking goes, and the model will always pick the single highest probability token, so the system should behave deterministically. In practice this is not quite true. Even with temperature locked at zero, architecture level non-determinism does not fully disappear.

The reason is that token selection does not happen at the level of whole words the way we intuitively imagine it. It happens at a much finer grained subword level. A single word can be decomposed into multiple byte pair fragments inside the model, and the exact path that decomposition takes can shift subtly between runs. Layer on top of that the way floating point operations get parallelized, and the way GPU batch processing can change the order calculations happen in, and you end up with a setting that is theoretically deterministic but practically still carries a small amount of probabilistic noise.

This matters in production because it breaks an assumption that almost all of traditional software engineering rests on. The systems most of us build every day assume that the same input produces the same output. We write tests around that assumption, design caches around it, and build reproducible bug reports around it. LLMs violate that assumption outright. If a team does not accept that the same input can legitimately produce a different output, the system will look fine in a demo and then behave in ways nobody predicted once it is running in production.

This does not mean non-determinism is always harmful. In creative writing or open ended conversation, variation is often exactly what you want. The real question is whether the rest of the production system is prepared to receive that variation. When it is not prepared, a property that should be an advantage turns directly into a source of outages.

## The Second Trap: Prompt Sensitivity

If non-determinism lives inside the model, prompt sensitivity lives in the relationship between input and output. It is strikingly common to leave a prompt almost entirely unchanged, swap out a single word, and watch the result shift dramatically. Adding one sentence, reordering a phrase, or even inserting or removing a single line break can flip the model's entire answer.

This is dangerous for two distinct reasons. First, a prompt that worked reliably in development can fall apart against the range of real user phrasing that shows up in production. A developer tests a handful of representative inputs, they behave predictably, but actual users never reproduce that exact phrasing. Second, this sensitivity makes debugging genuinely painful. An engineer trying to reproduce a bug will often type the original failing input slightly differently, watch the failure vanish, and conclude incorrectly that the issue is already resolved.

There is no way to eliminate prompt sensitivity entirely, but there are practical ways to reduce its blast radius. Structuring a prompt into clearly separated sections, such as role, context, instructions, and output format, tends to make the model interpret each section more consistently than a single unbroken block of text would. Running a regression test against a representative set of inputs every time the prompt changes also surfaces invisible sensitivity early, before it reaches a user.

There is an important shift in mindset buried in this observation. Instead of treating prompt sensitivity as a problem that disappears once you find the perfect wording, it is more useful to treat it as a background condition that can resurface at any time. Without that shift, a team can spend endless hours micro tuning prompt wording and never actually gain the underlying stability they are looking for.

## Why Models Invent Facts

The third root cause is what is commonly called hallucination, a term that unfortunately implies the model is doing something like deliberate deception. What actually happens is far more mechanical. When asked about something outside its training data, the model does not say it does not know. Instead it keeps generating the statistically most plausible next word, and the resulting sentence happens to read like a fact.

This shows up most clearly when the model fails to properly use information provided directly in its context, or when it leans too heavily on a pattern that was overrepresented in its training data. A common example is handing a model a reference document and watching it confidently produce a detail that document never contained. The same failure appears when a user unintentionally asks a question that falls outside the model's effective knowledge.

Here is the point worth pausing on: non-determinism, prompt sensitivity, and hallucination are not three independent problems. They share the same root. The model does not know the correct answer, it selects the next highest probability token. Once that root cause is clear, patching each symptom individually at the prompt level starts to look like the wrong approach. All three need to be handled together, at the level of system design.

That reframes the central question. How do you turn a component that fluctuates probabilistically into a part of a trustworthy system? The answer is not to make the model smarter. It is to make the boundary around the model sturdier.

## Contracts Turn Probability Into Engineering

The first boundary is locking down the shape of the output as a contract. If an AI produces a free form answer, the next system in line struggles to process it automatically. Natural language sentences are hard to parse, and there is no guarantee they will keep the same structure from one call to the next. For downstream systems to reliably consume this output, there needs to be an agreement about its shape established up front. Without that agreement, a small shift in how the model phrases its response can stall or misbehave every system that comes after it.

Structured output is the fundamental fix for this problem. Most LLM APIs now offer a way to force the response format into JSON. Define the shape in advance, and the model generates text that conforms to that shape, letting downstream logic be designed around a known structure. That said, this alone is not a complete guarantee of safety. Models do not always produce syntactically valid JSON, and it is common for the structure to be correct while some of the content inside it diverges from the intended schema.

A stronger form of contract is tool calling. When you ask a model to call a predefined tool, the input and output schema of that tool becomes the contract itself. The model can only invoke the tool by producing arguments that satisfy the schema, which gives this approach more enforcement power than JSON mode alone. This is especially valuable in agentic systems. When a task is completed through a sequence of tool calls, the clearer each tool's contract is, the more predictable the entire execution flow becomes.

Whichever mechanism you choose, a validation layer has to sit at the end of it. Run every model output through a validation library, and treat anything that violates the contract as an error immediately. Skip this layer and malformed output quietly flows into the rest of the system, only to surface as a confusing failure somewhere else entirely, far removed from its real cause. Pairing a contract with validation is the first concrete practice for containing a probabilistic component inside a deterministic system boundary.

## Retries Are Not a Universal Fix: Splitting Failure Into Three Kinds

The second boundary is how failure gets handled. When a model call fails, the natural instinct is to retry immediately. Network errors and transient problems really do resolve themselves through retries a lot of the time. But not every failure is fixable by trying again. If the model produced false information or made a bad judgment call, resending the exact same request does not remove the underlying cause. It might simply return a different wrong answer instead.

This is the trap hidden inside naive retry logic. A retry that has not actually solved the underlying problem still lets the system behave as if it has. From the user's perspective a normal looking answer arrives, but what actually arrived is just a different flavor of wrong answer. Left unchecked, this pattern produces the most dangerous kind of failure mode: one that keeps silently recurring while the system appears, from the outside, to be healthy.

Designing retries well starts with splitting failures into three distinct categories. The first is transient failure, caused by things like network errors, momentary overload on the model server, or rate limiting, and these tend to resolve on their own given time. Retrying is genuinely effective here. The second is permanent failure, which happens when an API key is invalid or the model simply does not support the requested operation. Retrying this kind of failure produces the identical result every time, so it is nothing but wasted time and wasted cost.

The third and most difficult category is result failure, where the model does return a response, but the content of that response does not match what was expected. A structured output request that comes back malformed, an answer that contains fabricated information, or a judgment call the model got wrong all fall into this bucket. Retrying here might produce a better result, but it carries an equally real chance of reproducing the exact same problem again. A system that retries indiscriminately without distinguishing these three categories ends up wasting resources on permanent failures while masking result failures behind the illusion of a resolved request. When retries are warranted, exponential backoff is the standard approach: wait one second before the first retry, two seconds before the second, four seconds before the third, and so on. This buys transient failures time to clear on their own without piling additional load onto an already strained model server.

## You Cannot Manage What You Do Not Measure

The third boundary is observability. In traditional software, logic tends to be explicit and output tends to be guaranteed, so logs and metrics alone are often enough to understand what a system is doing. AI systems break that assumption. With a probabilistic component in the loop, output is never fully guaranteed, and detecting and responding to that instability requires a much closer look at the system's actual behavior.

Observability, in this context, is the ability to infer a system's internal state from the signals it exposes externally. Traditional monitoring is closer to checking a system's static condition, whether a server is alive, whether response times sit in a normal range. Observability is closer to reading a system's dynamic behavior patterns over time. This capability matters especially for AI systems, because understanding why a failure occurred, and why a particular output came back, is the only way to actually stop that same failure from recurring.

Managing quality requires being able to measure quality in the first place, and the first practically useful metric is structural validity rate. This is the share of all responses that came back matching a predefined structure. If you are using JSON mode, this is the percentage of responses that were valid JSON. A sharp drop in this number is a reliable signal that the model's behavior has shifted, or that a prompt change had an unintended side effect.

The second useful metric is semantic validity rate: among the responses that were structurally valid, the share whose content was also actually correct. This can be measured automatically through validation logic, for example checking whether a specific field's value falls within an acceptable range and tracking the pass rate over time. A low number here means the structure is fine but the content frequently is not, which is a clear signal to revisit the prompt or rework the validation logic itself. Watching both of these metrics continuously over time is the only reliable way to turn an invisible property, system health, into a visible number a team can actually act on.

## Conclusion: Design for Unpredictability, Do Not Fight It

The four things covered here, understanding the root cause of non-determinism, building contracts through structured output, classifying failures before deciding whether to retry, and continuously measuring quality, look like four separate concerns on the surface. They converge on a single stance. Stop trying to control what an LLM outputs, and instead design the boundary that output has to cross on its way into and out of your system.

This shift in stance matters because it is not realistic to expect non-determinism or hallucination to simply disappear as models get better. Models will keep improving, but as long as the underlying architecture keeps selecting the next token probabilistically, some form of unpredictability is likely to remain, regardless of how capable the model becomes. If that is true, the job of a production engineer is not to eliminate this property. It is to build a boundary sturdy enough that this property never gets the chance to take down the rest of the system.

What a team actually needs to do is not complicated to summarize. Force the shape of every output into a contract, and always pair that contract with a validation layer. Split every failure into transient, permanent, and result categories, and respond to each one differently. Watch structural validity rate and semantic validity rate continuously, and treat drops in either one as an early warning. None of these three practices are tied to a specific framework or a specific model, which means they apply just as well no matter which LLM sits behind your API.

If you want to go deeper into each of these patterns down to the code level, the companion ebook [Making AI Predictable](/assets/ebooks/making-ai-predictable.pdf) works through them in more detail.
