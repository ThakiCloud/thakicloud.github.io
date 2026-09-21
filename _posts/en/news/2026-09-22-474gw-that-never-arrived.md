---
title: "The Day 474 Gigawatts Never Arrived"
excerpt: "In one month in August, 474 gigawatts of interconnection requests came into the Texas power grid. 90% were for data centers, and a fact-check found two-thirds were closer to reservations. A recap of the day the numbers turned the AI power panic on its head."
seo_title: "The Day 474 Gigawatts Never Arrived, 67.7% of Power Applications Were Phantom and the Real Bottleneck for AI Data Centers"
seo_description: "A fact-check found 67.7% of AI data center power applications were fake or duplicated. The real bottleneck is not generation capacity but regional grid imbalance and deployment speed. Implications for Korea's 550 trillion won plan and enterprise AI execution."
date: 2026-09-22
last_modified_at: 2026-09-22
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - news
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/news/474gw-that-never-arrived/"
---

In August, one number had the Texas power grid on edge. In a single month, the interconnection requests filed with ERCOT, the operator of the Texas grid, topped 474 gigawatts. A large nuclear reactor puts out roughly 1 gigawatt, so this was that much capacity applied for in a single month. And 90% of those requests were for data centers. The AI boom was trying to swallow a whole state's power grid in a month.

Grid interconnection is structured so that positions are assigned in the order applications are filed. So even before demand forecasts are finalized, companies tend to apply for far more power than their actual construction plans call for. It is effectively an option: secure a spot in the line first, and let it go later if it is not needed. In the queue, a gigawatt is a seat, not electricity. The longer you hold the seat, the longer it takes to reach interconnection and the cheaper the power rate becomes. Because of that calculation, the numbers never told the truth to begin with. Once you know the structure, you can explain why the number is 474 gigawatts in a month. An application is, in the end, a bid stating the intent to secure power, and the single fact that the numbers are inflated makes this more a power story than an investment story.

But the story hiding behind this number was half a lie.

According to Impacton's fact-check article this week, 67.7% of the contracted capacity applications companies filed were fake or duplicated. The two-thirds of the huge 474 gigawatt figure was, in other words, close to a reservation ticket. In the interconnection waiting system, companies apply for more power than they actually need to secure options on future volume, sizing it for a plant that may never get built and servers that do not yet exist. The number itself is real, but the narrative that all this power will be consumed for AI is an exaggeration.

![Image visualizing the concept of the day 474 gigawatts never arrived](/assets/images/474gw-that-never-arrived-hero.webp)
*We visualized the article's core concept.*

## A Number That Is a Promise, Not a Bill

The problem is that this inflated number has been used as a premise in the "power panic" narrative. The logic is that AI power demand is so large that data centers can no longer be built, and therefore it can only be solved with renewable energy. This claim has dominated headlines for the past few years, and data center site selection and power policy debates were designed almost entirely on this premise. If the applications are phantom, then the policies and investment decisions built on top of them rest on phantom figures too.

This is exactly the point the fact-check rebutted with evidence. The demand forecast that backs the claim that "renewables cannot handle it" is itself inflated; in other words, the application numbers are inflated. And the conclusion that counter-question points to is the opposite. The more direct constraint is not long-term generation shortfall, but the speed of renewable deployment and regional grid imbalance. The phantom figure leaves one more question: when demand misses the mark, who bears the grid investment costs already sunk. In the United States that question has caught fire as a debate over overestimation, and in Korea it remains as a risk of over-concentrated investment in the capital region.

## Efficiency That Outpaces Demand

The core of the article is one line. The power efficiency of AI compute is improving faster than demand is growing.

There are three levers. First, model sparsity. A design that activates only a small fraction of parameters, so the same question takes far less compute. Second, improvements in PUE, the data center energy efficiency metric. Third, demand response. A technology where, when the grid asks a data center to pull the lights down for a moment, the data center answers yes, we will reduce. In an experiment validated by EPRI and NVIDIA, a GPU cluster in an AI data center cuts its output by 30% in 40 seconds. Machinery that used to pay a fixed electricity bill has now become an entity that can negotiate with the grid. From the grid operator's view, this change is even bigger, because the AI load that previously had to be absorbed no matter what has become a controllable resource.

The key is that the three levers move together. Sparsity reduces power use at the model layer, PUE at the building layer, and demand response at the operations layer. It is not a structure where improving just one of them is enough; as all three layers improve at once, the demand curve bends down and the efficiency curve climbs. Miss the crossing point of these two curves, and the power panic will keep getting reproduced.

The macro figures point the same way. If the renewable expansion in the 12th Basic Power Plan is carried out, capacity grows from 37 gigawatts in 2025 to 220 gigawatts in 2040, and the supplyable generation at that time is said to exceed the additional data center demand by 3.5 times. In other words, it is not a question of whether there is enough, but how fast and where it arrives. The direct constraint the fact-check points to is "the speed of renewable deployment and regional grid imbalance," not the limit of generation itself.

## The Real Bottleneck Is the Grid, Not the Power Plant

So where is the real bottleneck? Not the power plant, but the grid. Because power is used where it is generated, the substance is not national total capacity but regional balance. In Korea, more than half of the capital region's supply applications are judged infeasible, and the output curtailment rate in Honam also exceeds half. It is a structure where power generated in Honam and demand concentrated in the capital region never meet. Power that looks surplus in total terms disappears when you put it on the map.

The point where this imbalance touches developers is grid interconnection. The reliability of demand forecasts, regional grid headroom, and interconnection cost and timing. As these three come to set a project's price and schedule, the perspective that reduces a power problem to a regional one becomes essential.

At the same time, abroad, efficiency and power source are becoming law. Germany mandates improving PUE from 1.5 to 1.3, and China limits new large data centers to a PUE of 1.3 or below. Ireland ties new data center interconnection to a condition of sourcing at least 80% from renewables, and the EU has made energy performance reporting mandatory. The criterion for data center location is moving from where power is cheap to where the grid is clean and interconnection is fast. If a company uses data centers or cloud abroad, how clean that region's grid is now becomes part of the contract terms. Because it becomes a variable on the table for RE100 and Scope 2 obligations, and for PPA negotiations.

This week, the power layer was standardized too. NVIDIA is pushing a full-stack strategy that standardizes compute, software, facilities, and power into one stack, and LG Energy Solution put its name on the AI data center power storage, i.e., BESS supply chain, through DSX-ready certification. The claim that the bottleneck of AI infrastructure is power, not chips, is no longer a forecast; it is already a confirmed market.

## Korea's 550 Trillion Won Plan, and the Capital Markets Started Discounting First

The implication for Korea is direct. As part of the Grand Leap's three mega-projects, the government is pushing to build 18.4 gigawatts of AI data centers, roughly 550 trillion won, by 2035. SK Telecom has revealed a blueprint to bring 5 gigawatts online in stages starting in 2029 and expand to 15 gigawatts in the long term, and has even set up a dedicated business development company. As telecoms, cloud operators, and NeoClouds stand on the same grid, competition is getting hotter, and utilization, customer acquisition, and power supply management are growing into variables that decide success or failure. The larger the plan, the more power security and regional grid interconnection timing will determine everything.

In the meantime, the capital markets lit up the warning signs first. The IPOs of data center and AI infrastructure companies have been postponed one after another. Local community backlash over rising electricity rates and environmental burden, the interest rate environment, and political risks that have become issues for both parties ahead of the U.S. midterms have all piled up. The market no longer accepts without question a valuation based on a backlog of orders that has not yet been validated in revenue. The New York Times has called this an unusual setback for the AI industry. The formula is simple. When the power story wobbles, the valuation gets discounted first.

The competitive landscape compounds it. As GPU cluster investment spreads across telecoms, cloud operators, and NeoClouds, overcapacity and power supply burden are being raised at the same time. The bigger the plan, the more that if there is no answer to who, where, and how much, the capital markets will leave first.

The same formula applies to Korea. In a situation where capital region concentration, power shortage, and permitting issues are already cited as key location risks, the path confirmed in the United States, that "power and community backlash transfer into capital market discounting," extends directly to domestic AI infrastructure investment. The lesson for Korean companies is also clear. In the next infrastructure competition, securing a site and interconnecting to the grid becomes as important as securing GPUs. And for companies using that infrastructure, how to run workloads becomes a cost variable that reaches directly into the electricity bill. In the end, the Korean version of this news is not to assume the 550 trillion won plan, but to test the premise itself.

## The Day Workloads Themselves Become Grid Resources

Let's turn the conclusion toward companies. The deepest implication of the fact-check is not that the power crisis was an exaggeration, but that the way workloads are executed can become a power policy variable. If cutting 30% in 40 seconds is a structure rather than a one-off, the next question is the design of execution that runs work which can wait into cheap hours and clean hours.

And among enterprise AI workloads, the one that fits this condition best is non-real-time automation work. Like a patrol, like a report, like a backup. Work that can wait, work that can repeat, work that can be late. If automation only works in the hours when the grid produces surplus power, that company becomes not a customer of the grid but a member of it.

The enterprise version of that question already exists. The moment the token cost of running automation and the electricity bill are written into the same ledger, the question of "which model is cheaper" changes to "when, where, and with which model to work." And in reality, there are few products that treat that design problem as an execution variable from the start.

Through the Paxis lens, the meaning of today's numbers is simple. Paxis is ThakiCloud's agent-native cloud, and it is already a formal product at v1.1 GA. Here, the grid's constraints are taken in as execution design variables from the start. Non-real-time agent work is automatically placed into low-cost hours and renewable surplus hours, and the CostRouter that picks a model per task sets a floor on the cost of finishing one piece of work even when the electricity rate wobbles. Because every execution leaves an audit log, the question of who bears the grid investment cost is answered on the ledger, not over a dispute. Execution happens inside isolated sandboxes, and for customers who must operate in a specific region, on-premises, it is provided as a sovereign K8s platform.

When the grid starts the question, the side that makes the answer is the workload. That is why the company that runs automation as a demand-side resource first becomes the grid's first customer. It is the only way to read the 474 gigawatts that never arrived, today.

## References

This article was written by synthesizing the news below.

- The Tracker, [[Exclusive] LG Energy Solution Obtains NVIDIA 'DSX-Ready BESS' Certification](https://thetracker.co.kr/View.aspx?No=4237510)
- Impacton, [【Fact Check】67.7% of Power Applications Are Phantom... AI Data Center 'Renewables Impossible...'](https://www.impacton.net/news/articleView.html?idxno=20392)
- Beta News, [SK Telecom's 42 Years, Beyond 'No. 1 in Telecom' to an AI Infrastructure Company... Restoring Trust, Revenue...](https://www.betanews.net/article/view/beta202609220001)
- Global Economic, ["Sending Local Code to a Server Without the User's Knowledge"... China's Zhipu AI, New...](https://www.g-enews.com/view.php?ud=2026092117281242920c8c1c064d_1)
