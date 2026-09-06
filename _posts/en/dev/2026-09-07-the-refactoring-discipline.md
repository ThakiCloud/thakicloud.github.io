---
title: "Don't Fix the Ugliest Code First. Fix the Most-Touched Code."
excerpt: "If you maintain a codebase you own, the order in which you fix it matters more than any technique. The first code you should touch is not the ugliest but the most frequently changed, because the cost of bad shape is paid only at change time. This article argues that case end to end, from git history hotspots to the anchor, one step, verify, commit loop."
seo_title: "Refactoring Priority: Change Frequency, Not Ugliness"
seo_description: "Why frequently changed code beats ugly code in refactoring priority, and how to improve it safely with characterization tests and one step commits. A maintenance playbook for solo developers."
date: 2026-09-07
last_modified_at: 2026-09-07
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - refactoring
  - software-maintenance
  - solo-developer
  - code-quality
  - characterization-test
  - technical-debt
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-refactoring-discipline/"
ebook: /assets/ebooks/the-refactoring-discipline.pdf
ebook_title: "The Discipline of Refactoring"
ebook_pages: 31
---

If you have spent years maintaining a codebase you own, all alone, this article is for you. You will get one yardstick and one procedure: how to choose what to fix first, and how to fix it without breaking behavior.

The conclusion up front: the first code you fix should not be the ugliest. It should be the most frequently touched. Most developers line up their codebase by how much it hurts to look at, and start at the front. That ordering is almost always a waste of time, because the cost of ugliness is paid only when you change the code.

The argument below works through that single line: why change frequency, not aesthetics, becomes the yardstick, where the frequently changed code actually shows up, what must be in place before you move a single line, why the unit of movement has to stay tiny, and how to keep it all running without relying on willpower.

![Illustration of the core idea of Don't Fix the Ugliest Code First. Fix the Most-Touched Code.](/assets/images/the-refactoring-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## Ugliness Is Free. Friction Is a Monthly Bill

Start with a small experiment. Remember your last bug fix. Compare the time you spent on the fix itself with the time you spent finding where the fix went. For maintainers, the finding time is almost always the longer one. That ratio is the real cost of bad shape. A bad shape does not slow down the work itself; it slows down the search for where the work is.

Now look at the cost through time. Ugly code that you rarely change costs you nothing in the meantime. You pay for ugliness only at the moment you change it, and if you never change it, you never pay. The rereading burden, the confusing names, the anxiety about the unknown, none of that becomes a cost while the code sits still. Code you touch five times a month, by contrast, pays friction every month: rereading context, rechecking assumptions, rerunning checks.

Put numbers on it. Suppose a function makes you read an extra 15 minutes every time you change it, and you change it four times a month. That is one hour paid every month. Spend 30 minutes making the shape of that function easier, and from next month you save 30 minutes monthly. The payback is one month. Keep changing that function for two more years and the total comes to roughly 72 hours of net gain. Now put the same ugliness in a function you change once every three months. The same 30-minute investment then needs about eight months to pay back.

Identical ugliness, different location, completely different value. The two cases above are not more ugly code versus less ugly code. They are frequently changed code versus rarely changed code. So the first question in any fix ordering is never how ugly it is, but how often you will touch it again. It is the same logic as in operations, where you watch the service that fails often before the old, ugly, stable one.

## The Fix List Comes From Git History

How do you measure change frequency? Do not rely on memory or feelings. Your git history has already recorded it. Take the commits from the last six months, count how often each file changed, and list them from most to least. The top of that list is where refactoring investment goes.

```
git log --since="6 months ago" --name-only --oneline | sort | uniq -c | sort -rn | head -20
```

That command produces the list of most changed files over the last six months. If one file occupies most of the top ten, you no longer have an opinion. You have evidence.

The list tells you where. Once you open those files, you need to recognize what shape of problem you are looking at. The five shapes that most often create friction in maintenance are a function doing several jobs, the same logic copied in more than one place, one logical change rippling across many files, deeply nested conditionals, and unnamed numbers or strings floating through calculations. Of these, duplication and the rippling change are the ones that most directly slow down your next change.

You can also see smells before you open the file. A file named util, helper, or manager is usually a junk drawer where logic that has no home gets dumped. Commit messages like fix again, temporary handling, or do not touch this are direct evidence that the code created friction. Skim those three signals first, then open the file, and your judgment arrives much faster.

## Three Kinds of Ugly Code You Should Not Touch

The reverse list matters as much as the forward one. There are three kinds of ugly code you should leave alone. The first is dead code: replaced features, settings nobody reads. You do not decorate code you will not touch, and for most of it the answer is deletion rather than refactoring. Deletion is the highest payback refactor available to a solo developer. The only caution: verify with real references, not with your memory that nothing uses it.

The second is code whose behavior you cannot verify. No tests, and testing is hard because the function is tangled with file input and output, databases, the network, or timing. Large moves in that code are a gamble. There, only the most conservative moves earn their place: renames, constant extraction, and the work of widening the tested area.

The third is shape complaints. If the structure were just a little different, it would be better. That is a legitimate thought, but it sits at the bottom of the priority list. If the code is ugly, changes at zero frequency, and creates little friction, the beauty you would gain is visible only to you, and you would pay for it with regression risk that only you carry.

All three share one property: fixing them feels satisfying, but none of them pays back. The change frequency yardstick exists precisely to protect you from that kind of satisfaction. When you catch yourself itching to fix code that does not change, stop and ask when the payback arrives. If you cannot answer, then that code is not for this week.

## Do Not Move a Single Line Without an Anchor

The yardstick and the list are in place. Now the harder question: how do you actually move code without changing what it does? The promise that behavior stays the same is a hollow one without a verification means. Move code without tests, and the only way to know whether behavior changed is to run the app and look, which is not trustworthy when several features are in flight at once.

So the first step of any refactor is installing an anchor. If tests exist, run them all green and commit that baseline. If they do not, write what is called a characterization test. Its goal is not to verify correct behavior; it is to record current behavior, exactly as it is. If the current behavior has a bug, the test records the bug. Do not fix it. Recording comes first; fixing later is a different procedure.

The procedure is simple. Choose representative inputs: normal cases, boundary values, error cases. For a pricing function, four to six inputs is enough. Run the current code and write down the outputs, literally copy them. Turn those outputs into assertions as expected values. The moment the test goes green, the anchor is installed. From that point on, if you change the shape and an output changes, the test stops you.

A concrete example. Take a pricing function with discount logic. Choose four inputs: a gold user in June, a gold user in December, a silver user in December, and a silver user holding one coupon. Run the old code and record the discount it produces for each. The current behavior is now pinned by those four records. While you reshape the function, nothing can move those values. If the function is tangled with file I/O and hard to test, do not anchor the whole module. Anchor the pure leaf functions inside it, the ones where the same input always gives the same output. The anchor is a ladder. You climb it rung by rung.

## One Step, Verify, Commit

The procedure from here has five steps: anchor, one step, verify, commit, repeat. The core is the words one step. Do only the smallest unit of change: rename a variable, extract one function, move one line. While you are in that step, doing just this too is forbidden. That just this too is the entrance to the big cleanup.

Why is one step the maximum unit? The reason is failure explanation. Do one step and a test goes red, and the cause is almost certainly that step. Do three steps at once and a test goes red, and you cannot tell which of the three broke it, so debugging begins. One step keeps failure inside the range where you can explain it. That is the boundary between refactoring and debugging.

There is a menu of small moves, ordered from safest to riskiest. Renaming is the safest, and it forces the question of what is this thing. Extracting a constant limits the blast radius to wherever the number was used. Flattening deep nesting with an early return is low risk and pays off immediately. Extracting a function is a step bolder, and moving a function between classes changes structure, making it the riskiest of the small moves. The two common mistakes are cramming several moves into one session, and skipping verification because it should be fine.

A practical boundary to add: if a fix takes three lines, do it on the spot. A rename, a constant, an early return. Writing a small job in a backlog and reentering its context later costs more, often, than just doing it. But the opposite discipline exists too. If a three-line fix swells to thirty lines halfway through, stop. It is no longer a small fix; it is a project, and projects go back to the one step procedure. Most refactoring failures do not happen in the fixing. They happen at the moment you fail to decide whether something is a small job or a project.

## Rhythm, Not Willpower

A technique that only runs when you feel like it rots. The plan that refactoring will happen on the weekend almost never survives: the weekend never comes, or it arrives and gets eaten whole by a bug, and nobody else fills that time. So the allocation is a share inside feature work. When you estimate a feature, add roughly one fifth as a shape share. A three-day feature estimate carries six to eight hours of small moves in the territory the feature already passes through.

That time is restricted. You only refactor files you are already touching for the feature. The benefit of the restriction is twofold: you cannot drift into a big cleanup, and your tests and context are fresh, made moments ago. If you do not use the shape share, that is also a signal: the territory was easy to work in. Record it. You do not invest in easy areas.

Once a week, hold a fifteen-minute review meeting with yourself. Friday afternoon works well. Three actions. First, look back over this week's commits and find the hard ones: the one whose message took time to write, the one that touched many files, the one followed by another fix. Those are friction marks, and where they are is this week's hotspot. Second, reconcile the refactoring log: which entries did you touch this week, which did you not. Do not delete the untouched ones. Re-decide them: next week, or never. Finally, choose one item for next week. One. Write a single line at the top of the log: location, move, expected size.

There will be weeks when debt rises faster than you can pay it. Features are urgent, bugs follow one another, and the shape share is the first thing eaten. A solo developer has one privilege: choosing their own speed. In a heavy debt week, deliberately make this week's feature smaller. Drop one nice-to-have. It feels like a loss, but it is a repayment. Accepting the same workload as last week would be borrowing, and borrowing carries friction interest. The test is simple: after the fifteen-minute review, is there still unease? If the review cannot remove the unease, the speed is still too fast.

## Code Shape Is an Asset That Pays Back Next Week

How do you know this discipline is working? Vanity metrics are lines deleted and functions extracted. Those numbers can rise while the code gets worse. Measure instead: the time from receiving a change request to committing it with confidence, the average commit size, and the frequency of fixing one feature and breaking another. One metric a month is enough. The purpose of measurement is correction, checking that the change frequency yardstick, the small moves, and the weekly review are pointing where they should.

The record can be a single line. At the bottom of the refactoring log: August first, payment function fix, forty minutes reading plus twenty minutes writing. September first, same function, fifteen minutes reading plus twenty minutes writing. The value is not in the numbers. It is in having to write them. Once you write them, you learn that the time that felt long actually got short.

Tie it together. Code shape is an asset that grows every time you make the next change easier, and the next change arrives sooner than you expect. The small step you take today is collected in next week's work. Ugliness that never changes costs nothing. Friction that changes often compounds. That is why the fix order follows change frequency, and why an anchor, a one step, a verification, a small commit, and a fifteen-minute review stand between that investment and gambling.

The full version of this argument, the smell list with priorities, the loop with stop criteria, the five-day legacy starter routine, and the worked pricing example, is in the ebook The Discipline of Refactoring, thirty-one pages of it. If you want to go deeper than this article, that is where to go.
