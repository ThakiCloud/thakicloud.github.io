---
title: "The Model Is a Byproduct; the Factory Is the Product"
excerpt: "Recursive used automation to build its first model in four months, and Mirendil's agents wrote 99% of the pretraining code. Two reports from model makers point to the same place: not the model, but the factory."
seo_title: "Why the Model Is a Byproduct and the Factory Is the Product | ThakiCloud"
seo_description: "Recursive's four-month model build, Mirendil's 99% agent code, and Nvidia's GTC Berlin post-training claim. Reading this week's AI news through the lens of the factory."
date: 2026-10-22
last_modified_at: 2026-10-22
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - model-factory
  - training-automation
  - open-weight-models
  - post-training
  - nvidia-gtc
  - inference-distribution
  - llmops
categories:
  - llmops
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/ai-model-factory-becomes-product/"
---

The reports that model makers released this week read like factory reports. Recursive built its first AI model in four months of automation, and the subject of the sentence is the automation. Mirendil's AI agents wrote 99% of the code used to pretrain a frontier coding model. The two reports look different on the surface. One describes how long it took to build a factory, and the other describes who wrote the factory's code. Read alone, each is a standalone news item. Placed side by side, they point the same direction: in the model race, what is scarce is shifting from weights to the factory that produces weights. These two reports do not sit in isolation in this week's news. A chip maker packaged the factory's post-training stage as a product, and a frontier lab finished distributing its model to all three major US clouds. Put on the same page, they form one picture: the factory gets faster, its output moves to the shelf, and outside the shelf, the factory itself starts being sold.

![An image visualizing the concept that the model is a byproduct and the factory is the product](/assets/images/ai-model-factory-becomes-product-hero.webp)
*The article's core concept, visualized.*

## Four Months: Recursive's Factory Report

According to HuggingNews, Recursive built its first AI model in four months of automation. The model is called Flint, a 40B-parameter open-weight machine learning system that runs at more than 125 tokens per second on an M4 Pro MacBook Pro.

The number that stands out is not the 40B but the word first. A model company's first model is its founding report: who the company is, what it can build, and at what cost. In the past, a startup's first model arrived only after a team of dozens had borrowed a cluster, and the unit of time was years. Staff up, lay down the data pipelines, run training, break it, run it again. That sequence ate a company's first year. Recursive's report shrank that unit to four months and moved the subject of the work from the team to the automation. It did not build one model faster. The act of building the factory itself was automated. When the time axis of the founding report changes, the height of the capital barrier changes with it. If preparing to build a model from scratch takes four months, the money that preparation costs becomes thinner in the same ratio. More companies enter where the lead time thins, and more entering companies mean more new models. That sentence is the ripple Recursive's report sends through the market.

There is weight in the fact that the model is open-weight and runs at a speed you can feel on a laptop. The factory's output no longer has to live in a data center. When a 40B system puts out more than 125 tokens per second on an M4 Pro MacBook Pro, the model becomes an output a single developer can put on a desk. In the factory report, this is a sentence about where the product ships: the set of places the output can be used has widened.

## 99%: Mirendil's Factory Report

Mirendil's report is about the factory code itself. Mirendil's AI agents wrote 99% of the code that will be used to pretrain a frontier coding model. After replacing its entire engineering team with AI agents, the company moved on to post-training for its first large-scale coding model.

99% is more than a productivity figure. The code that trains a model is the factory's blueprint. Data pipelines, training loops, evaluation harnesses, the scripts running on the cluster: all of it is factory code. When the agents write the blueprint, the factory's improvement loop closes inside the AI. A model writes code, that code trains the model, and the next model writes better code. What the loop means is speed: model improvement is no longer bounded by the pace of human engineering. When people wrote the code, moving from one model to the next took a quarter. When 99% of the code comes from the agents, that quarter compresses to the wait time for the loop's compute.

One distinction matters. The code Mirendil's agents wrote is the code used to pretrain a frontier coding model. The factory's blueprint is now 99% the work of AI. The moment the means of production overlaps with the kind of product, improving the factory becomes replacing the model inside the loop. The human role shifts accordingly: away from writing code, toward deciding which model to build, in which direction to improve it, and which risks to take. In an automated factory, those three decisions are the human's work.

The two reports describe the same factory from different faces. Recursive says the factory can be built in four months. Mirendil says 99% of the factory code comes from AI agents. One is a statement about construction speed, the other about who runs the factory. Read together, they show what this year's model race will be measured by: how fast the factory can turn.

## Same Week: the Chip Maker Sells the Factory Too

A report in the same direction came from the chip maker's stage. At the opening keynote of GTC Berlin 2026, Nvidia CEO Jensen Huang presented enterprise post-training results for the newly released Nemotron 3.5 Super VL. According to Nvidia's presentation, the post-trained Nemotron 3.5 outperforms GPT-6.1 Sol at a cost 25 times lower. A chip company announced that it will sell enterprise post-training as a product. When a company that sells chips also sells the post-training process that runs on those chips, the boundary of what the product is moves from the chip to the factory.

Post-training is the factory's final assembly stage. The base model comes off the production line, and post-training assembles it to fit the enterprise's work. When the chip maker packages and sells that stage, the enterprise can take in final assembly without building its own training factory. This is a movement in the same direction as the two reports. Recursive automated the factory itself, and Mirendil handed the factory code to the model. Nvidia says the enterprise need not build even the post-training stage.

The model it is measured against, GPT-6.1 Sol, is also the model OpenAI finished distributing to all three major US clouds this same week. According to HuggingNews, under new distribution agreements OpenAI now serves GPT-6 Astra, GPT-6.1 Sol, and GPT-6 Luna from Google's Model Garden. The expansion puts OpenAI's models on all three major US clouds. The same model name is used in two completely different roles. In one report it is the product on the shelf. In the other it is the benchmark to be beaten.

Put the two sentences together and a gap in prices shows up. GPT-6.1 Sol is a frontier model being sold from the cloud at this very moment. Nvidia is selling enterprises a post-trained model that beats it at a cost 25 times lower. The shelf price and the factory price land on the same page in the same week. The old logic was to make a model and put it on the shelf. The new logic is to sell the means of making the model. On this week's news page, the two logics run on different floors: one widens the model shelf, the other sells the model factory.

## When the Cycle Shortens, the Buyer's Question Moves

Factory automation shortens not just the maker's schedule but the product's shelf life. A model used to be an asset you bought once and ran for years. The next version arrived on a yearly cycle. If new models come every four months and the post-training stage is claimed to cost a quarter as much, the depreciation curve of the model asset steepens. Picking a model and locking it in becomes holding inventory that expires next quarter.

The buyer's question changes accordingly. Which model is the best was a valid question in a slow cycle. In a fast cycle, the valid question is how do you absorb a model that arrives every four months: which tasks to bind to which model, what hardware to run it on, what permissions to grant, what to block when it fails. All of these are questions of factory operation.

Absorbing a model is a concrete list of work. Add the new model to the catalog. Decide which tasks move to it. Manage the 25-fold cost differences between models at the task level. Record how far execution has gone. This list used to be fine updated by the quarter. If a new model arrives every four months, the list needs a hand every month. It is the cycle in which the model stops being something you pick and becomes inventory you manage.

In a fast cycle, the side that turns the execution environment at the speed of model supply gains, and the side that cannot loses. There is one more asymmetry. A model can be swapped next quarter. It is inventory, so when the shelf life ends, you take in the new one. The execution environment cannot be swapped next quarter. Changing the environment is much slower, much more expensive, and shakes the whole organization. The faster the supply cycle, the more the advantage goes to the side that can turn the environment early. The outlook this week's two reports give the buyer side is this one sentence. Models arrive every four months, final assembly is sold at a quarter of the cost, and open-weight models at laptop speed become a real option.

## Where Paxis Stands

ThakiCloud's Agent-Native Cloud, Paxis, is the formal product that answers this question. It has reached v1.1 GA. Models and agents, the factory's output, become assets only when the execution environment can operate them at whatever speed they arrive.

Paxis treats Skills, Tools, Policies, and Audit Logs as first-class resources. It stages autonomy from L0 to L3, a policy gate checks behavior before execution, and the audit log records what was done. Isolated sandbox execution absorbs the side effects of execution, and MCP connectors and the skill market handle external integration. An open-weight model at laptop speed runs inside the company on sovereign, on-prem K8s (ai-platform). CostRouter picks the model per task, so as the cycle shortens, the hand that does the picking moves from the person to the platform.

This week's two factory reports say the same thing. The factory gets faster, and the model becomes the byproduct. The value that remains in that market is the execution environment that takes the byproduct in and runs it.

## References

This post summarizes the following news.

- HuggingNews, [OpenAI Launches GPT-6 Models on Google Cloud to Reach All 3 Major US Clouds](https://huggingnews.com/ai/openai-launches-gpt-6-models-on-google-cloud-to-reach-all-3-major-us-clo-b4924700)
- HuggingNews, [Recursive Builds First AI Model via Automation in 4 Months](https://huggingnews.com/ai/recursive-builds-first-ai-model-via-automation-in-4-months-3c9b65a4)
- HuggingNews, [Nvidia's Huang Touts Post-Trained Nemotron 3.5 Beating GPT-6.1 Sol at 25x Lower Cost](https://huggingnews.com/ai/update-nvidias-huang-touts-post-trained-nemotron-35-beating-gpt-61-sol-a-adc2ae59)
- HuggingNews, [Mirendil's AI Agents Write 99% of Code to Pretrain Frontier Coding Model](https://huggingnews.com/ai/mirendils-ai-agents-write-99percent-of-code-to-pretrain-frontier-coding-3e88e9d7)
