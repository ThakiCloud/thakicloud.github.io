---
title: "At the Same Price, the Blocker Wins: We Price the Unattended Agent's Verifier Placement in Dollars"
seo_title: "Pre-Action Gating and Post-Action Verification for Unattended K8s Agents: The Safety-Cost Frontier - ThakiCloud"
seo_description: "When you attach a check model to an agent running an unattended cluster, we settle where that check happens in dollars. We derive, in closed form, the breakeven points of the four placements: blocking before execution, watching after execution, doing both, and doing neither."
excerpt: "Think of a home renovation. The master blocks before the hammer falls. The inspector looks at the wall after the work is done. This paper values these two seats in dollars. At the same price the blocker wins, and having both is the cheapest."
date: 2026-09-01
last_modified_at: 2026-09-01
tags:
  - pre-action-gating
  - post-action-auditing
  - verification-placement
  - safety-cost-tradeoff
  - autonomous-agent-harness
  - k8s-incident-ground-truth
  - world-model-gate
  - frozen-model-tier
  - llm-as-judge
  - false-block-cost
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/verification-placement-safety-cost/"
---
At the same price, the blocker wins. This post is for Korean cloud and AI engineers who run agents that operate clusters with no one on site, or who set the safety budget for those agents. We show, in numbers, where to spend the money that goes into the 'verifier' watching over an agent. Today we introduce a paper our research team wrote autonomously.

## In Short

Picture a home renovation. An employee renovates a house alone, and two people can stand watch over that work. One mistake by the employee is no small loss.

One is the master. He blocks before the hammer falls. "That wall is load-bearing," he says. When the work is blocked, the work stops, but the wall is not broken.

The other is the inspector. He comes after the work is done and looks at the wall. The wall is already broken. But if he finds the crack early, the cost is only the repair, and the loss to the neighbor below is prevented.

This paper values these two seats. The master is pre-action blocking (the gate), and the inspector is post-action checking (the audit). Both use models of the same tier and pay by the same token price list. What changes is not the model's capability but where the check happens.

## What We Tried

The paper's core contribution is one thing. It stands up the placement of the check as an independent axis and gives a criterion for valuing it in dollars. Research so far has asked which model to use and which harness to use. This time the question is where the check happens.

The target is an agent loop that runs a cluster unattended. Each cycle, the agent emits one cluster command. The pre-action gate looks at the command before it runs and blocks it if something is wrong. The post-action audit reads the record after execution and reports any suspicious trace.

![The cluster command loop where the pre-action gate blocks before execution and the post-action audit checks after execution](/assets/images/posts/research/verification-placement-safety-cost/fig1_action_loop_placements.webp)
*Each cycle, the agent proposes one cluster command. The pre-action gate can block it before execution, and the post-action audit can examine the outcome after execution. The verifier tier is fixed, and tokens are calculated at the public price list. This is a conceptual illustration, not a measurement.*

On top of that, the paper names each place where money is spent. The cost that hits the moment a risky command runs is direct damage; in the renovation metaphor, the cost of the broken wall. The loss that grows while nobody knows is the latent aftershock; it corresponds to the damage to the neighbor below. The repair cost paid once a problem is found later is the recovery cost. We also count the friction cost of wrongly blocking a safe command and the investigation cost of wrongly flagging a safe outcome.

It writes the expected cost of the four placements as formulas: no check at all, gate only, audit only, and both. For each placement it derives when it starts to earn and when it starts to lose; the breakeven point is also solved in closed form.

The paper computes two scenarios. One is production scale, where a single incident is expensive. The other is development and staging scale, where incidents are cheap. All verifier prices are pinned to public price lists.

## The Results

### At the Same Price, the Blocker Is Better

Set the two at the same price, and one point of audit recall is worth only 0.7 points of gate recall.

A post-action audit cannot undo what has already happened. The only thing it can reverse is part of the latent aftershock. So even at equal recall, one point on the blocking side outweighs one point on the watching side. In the production scenario, the gate catches 75 of every 100 risky commands, and the audit catches 88. With that combination, at the same price the gate wins.

In plain terms: with the same budget, spend on the blocking side first.

### Using Both Is the Cheapest

In the production scenario, no check costs $72 per action. Gate only costs $18, and audit only costs $28.7.

![Comparison of expected per-action cost across the four verification placements in the production scenario](/assets/images/posts/research/verification-placement-safety-cost/fig2_cost_by_placement.webp)
*At the production incident scale, the both-together placement ($7.20) is the cheapest, followed by gate only ($18.01), audit only ($28.72), and no check ($72.00). These are values from the analytical model, not measurements.*

Both together is $7.2, the cheapest of all. Keeping the master and the inspector side by side is the cheapest. The placement that buys the most safety is that same 'both'.

The money actually spent on the check itself sits two to three orders of magnitude below the breakeven point. There is that much headroom.

### When the Blocker Gets More Precise, the Watcher Gets More Expensive

The value a post-action audit adds on top of the pre-action gate is proportional to the gate's misses. When the gate catches almost everything, there is nothing left for the audit to buy.

At a recall of 60 percent, the added value of the audit is $17.3 per action.

![How the added value of the post-action audit shrinks as the pre-action gate's recall rises](/assets/images/posts/research/verification-placement-safety-cost/fig3_audit_value_vs_gate_recall.webp)
*For scenario A, the audit's added value falls from $17.30 per action at a gate recall of 0.60 to $1.28 at 0.97. These are values from the analytical model, not measurements.*

When the recall rises to 97 percent, it shrinks down to $1.3.

The line where the audit pays for itself moves with price. In the development scenario, an audit using the top-tier model is a loss once the gate's recall passes 97 percent. An audit using the cheapest model still pays for itself up to 99 percent.

*The precise thresholds are 0.9726 at the top-tier model price and 0.9865 at the cheapest model price. These are model values for the development scenario.*

In plain terms: the cheaper the inspector, the longer it is worth keeping. Even as the master improves, the point at which the inspector becomes unnecessary comes later.

## So What Should You Change

Put these results into a team's work, and four design rules come out.

First, always put the pre-action gate in front of state-changing commands. Direct damage hits the moment the command runs, and it is not something that can be undone after the fact.

Second, add a post-action audit when the gate is incomplete and the latent aftershock is large. The audit pays for itself when something the gate failed to block remains, and the damage from what remains is greater than the recovery cost.

Third, recompute the budget. Upgrade the gate or change the audit's tier, and the line where it pays for itself moves, so compute again. The cheaper the audit, the later that line comes.

Fourth, as the kinds of commands grow, keep the gate cheap first. Use rule-based checks for most commands and hand only the unresolvable ones to the model. Run the audit as a batch that reads many command records at once.

We also write down what this work leaves behind, one line each. For the company: a rule for measuring where to spend the check budget of our unattended cluster operations. For society: it lets organizations without a large operations team know what safe unattended operation is worth. For science: it sets up a third measurement axis, 'check placement', after model tier and harness design.

## What Not to Trust

First, none of the dollar figures come from a real cluster. They are results of running the model with the two scenario values. The paper separately designed a four-branch measurement protocol to calibrate this model against real measurements. The numbers in this post are values from before that execution.

The verifier tier is fixed. Swapping the model itself is not the axis this paper contests.

There is also the assumption that each action is independent. The model does not handle situations where incidents chain into each other or a risky task proceeds across multiple cycles.

The gate's recall and false rate are values that go into the model from outside. Reliability and bias issues that arise when using a model as the grader are treated as a separate research topic. The paper designs the protocol so that the audit sees only the outcome record and not the gate's judgment, which reduces that bias.

The scenario values are examples. Only after running the protocol with your own team's numbers can you actually use these rules.

---

You can see the paper's detail page here: [Pre- versus Post-Action Verification](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-01-verification-placement-safety-cost)

*In the body, we rounded numbers like 0.9726 to one or two decimal places for readability. The exact values are in the figure captions and in the paper.*
