---
title: "Git Is a Timeline, Not a Backup: The Solo Developer's Version-Control Discipline"
excerpt: "Treating git like a backup tool keeps the files safe, but the reasons and the states are quietly lost a little every day. For a solo developer, git's real value is a timeline you can ask questions of, one where yesterday's you can answer. This article walks through the checkpoint commits, the branches as free sandboxes, and the history that works as a search index for future you."
seo_title: "Git as a Timeline, Not a Backup: Solo Developer Discipline"
seo_description: "Why using git only as a backup quietly costs a solo developer a little every day, and how checkpoint commits, branches as free sandboxes, and a five-minute routine turn that cost into a reflex."
date: 2026-08-27
last_modified_at: 2026-08-27
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - git
  - version-control
  - solo-developer
  - commit-discipline
  - branches
  - reflog
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-version-control-discipline/"
ebook: /assets/ebooks/the-version-control-discipline.pdf
ebook_title: "The Version Control Discipline"
ebook_pages: 34
---

This article is for solo developers who treat git like a backup tool: make a repo, push to GitHub, and never think about it again. By the end, you will know what you are quietly losing every day and how a five-minute daily routine takes it back. The claim, stated first: for a solo developer, git is not a backup and not a collaboration tool. It is a timeline you can interrogate.

Most people start git for one reason, "in case something breaks." Once the code is in the cloud, the mental model becomes "if it breaks, I will fetch the old copy." For a while that is fine. The files are safe, and safety feels like the whole point.

The problem is that this model uses only a small fraction of what git actually provides, and the bill for the unused part arrives in pieces. An afternoon lost to undoing a change. An experiment abandoned because breaking things felt dangerous. Two hours spent remembering why a line was written a certain way. None of it shows up as a single itemized cost, which is exactly why it goes unnoticed. This article looks at the structure of that loss, and at the daily habits that remove it.

![Illustration of the core idea of Git Is a Timeline, Not a Backup: The Solo Developer's Version-Control Discipline](/assets/images/the-version-control-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## The Person You Need to Ask Is Yourself

Teams get git explained as a collaboration tool. For a solo developer, collaboration is not the point. Being alone amplifies the exact weakness that git fixes, which is your own memory. When you are refactoring and realize last night's version was better, there is no teammate to ask what that was like. The person you need to ask is yesterday's you, and without a record you cannot ask that person anything. The file is still there, but it does not know why it was written that way, what state it was in, or what to fix first.

A concrete case. You refactor a payment function, commit, run the tests, and something breaks. What you actually want is not "give me yesterday's whole file." It is "undo only this refactor and keep the other work I did after it." A tool that hands back a full-file snapshot cannot answer that question, because the real question is when this function last worked.

That is where the difference shows. A backup gives you yesterday's files. git gives you yesterday's state, the reason for it, and every state after it. A backup file is just a copy. A commit carries a message, and the message says why and what changed. Six months later, staring at a line and wondering why it exists, the message is the witness that does not rely on your memory.

So for a solo developer, git is a device for rewinding time, not a team channel. The rest of this article is about the discipline that makes you actually use that record.

## Three Costs You Pay Without Noticing

This cost is paid daily, not once, and each payment is small enough that most people never add it up. The first cost is the experiments you never run. If breaking something means you cannot come back, you stop trying new approaches and repeat what you already know. A solo developer's growth comes mostly from trying things not yet tried, and the fear of losing state is what blocks the trying. You end up not using the biggest benefit git offers, for no reason other than fear.

The second cost is the rollbacks you do by hand. Something breaks, and you either undo the change manually or restore a backup and start over. Both take time, and both risk losing work you never meant to lose. A setting change that should take five minutes becomes three hours, because you diff a backup against the current file line by line. But if that file had been committed in small steps, the suspicious range shrinks to a single commit, and reading one commit is a short task.

The third cost is the code you can no longer explain. When you open something you wrote three months ago and cannot remember why, you have exactly two options. Refactor by guessing, which risks breaking it, or leave it as is, which accumulates debt. Commit history gives you a third option, check, and it also tells you whether you have hit this same wall before.

These costs compound. Each one is small, but a year of them is a large sum. There is also a subtler one: when something goes wrong, you do not know where to start looking. With history, investigation starts from the last known good state. With only a backup, it starts from the files you have and whatever you remember. The starting point is what determines the investigation time.

## A Commit Is a Checkpoint, Not a Save

The discipline that removes these costs is simple: turn each worthwhile stage of the work into a commit. The key word is checkpoint. A save is a copy of the files. A checkpoint is a named point where the work is complete enough that you can return to it without losing anything. It passes three tests: it works, it is complete in meaning, and it is a safe place to stop.

This is where git's core mental model lives. A change is not a fact until it is committed. Uncommitted work is just work in progress, something you can throw away at any moment. Once you believe that, experimenting changes. You try the bold refactor, and if it fails, you go back to where you started. With a backup tool, saving is the scary part. With git, the commit is not the scary part. It is the part that leaves a place you can return to.

A full day, concretely. Tuesday, with a small service. In the morning you run status and log to see where you are standing. First you fix the bug reported yesterday and commit where the tests pass. Then you start a new feature and commit when the skeleton runs. In the afternoon you try a new approach and it goes the wrong way. One command back to the previous commit, and the wrong approach is discarded. It still exists in the reflog, which means you can look at it later.

The goal is not to commit a lot; this is not a rule about committing every typo. Meaningless states make the timeline noisy, and a noisy timeline collapses back into a lump. The standard is the three tests: if the state works, has a complete meaning, and is safe to return to, commit; if one fails, wait a little or stash. The two mentalities side by side:

| Dimension | Backup-tool mindset | Checkpoint git mindset |
| What you get back | The files of that day | The state, the reason, and every state after |
| Attitude to experiments | Change feels dangerous | Not a fact until committed, discardable |
| How you undo | Replace with a full copy | A specific change, one command |

## A Branch Is a Free Sandbox, Not a Team Feature

When people hear branch, they usually think of a team working in parallel. For a solo developer, a branch is something else: a free sandbox. In the data model, a commit is a node on a chain, and a branch is a name pointing at a node. Creating a branch does not copy any file. It creates one new name pointing at the current commit. That makes the cost of a branch effectively zero, and the mental model flips from "making branches is scary" to "branches are cheap, so make many of them."

Deleting a branch does not delete the commits: if they are reachable from somewhere else, they stay, and if not, the reflog holds them for a while. Fear of branches is the biggest obstacle to a solo developer's habit of experimenting, and a branch is the cheapest insurance git offers.

You do not need a branch for everything, but three situations call for one. Big, uncertain changes: refactors, dependency upgrades, structural work. Commit main to a stable state first, branch, and work there; if it fails, delete the branch and main is untouched. Trying two approaches at once: approach A on branch A, approach B on branch B, then compare. And work with its own rhythm, because doing it on main mixes in-progress with stable, and main stops meaning always deployable.

Name experiment branches with a try/ prefix: try/redis-cache, try/in-memory-cache. The name tells future you that this is an experiment, not confirmed work. A real week: you try a new cache layer on try/cache-v1, notice that approach A is slow, go back to main, and open try/cache-v2. When approach B wins, you bring only v2's work into main and delete v1. After a week of creating, comparing, discarding, and keeping, main was never once in an unstable state. That is the point.

## History Is a Search Index for Future You

A commit message is not writing for an audience. It is a search index you build for your future self. Conventional Commits gives it a shape: type, scope, subject. The type says what kind of change it is (a feature, a fix, docs, a refactor, a test, or tooling), the scope says where, and the subject says what. Solo developers often think conventions are for teams and they do not need them. With types, you can filter the log to show only fixes, or only features. Finding when a change was introduced becomes a search instead of a rereading exercise.

A more important rule: one commit carries one logical change. Suppose you are changing error handling and also want to rename a variable and also want to add retry. Make three commits: the rename, the error handling change, the retry. Later, if you want to remove the retry, you revert only the third commit and the first two stay. Put all three in one commit, and reverting removes all three.

The body is for when the reason is not obvious. If you fix a bug with a subtle cause, the body records how it happened and how you found it. Six months later, when the same class of bug returns, that body is the starting point of the investigation. The body is an investigation note for tomorrow's you, not a report. A practical threshold: if a diff runs past 300 lines, ask whether it can be split.

Follow these rules and the commit chain becomes the story of the project. Five lines and you can see: webhooks were added, a test step went into CI, retry logic was extracted, an idempotency key was added to payments, and a double-charge bug was fixed. If the messages are all asdf, the files are the same but the story is gone. There is no witness to explain why things became the way they did.

## Five Minutes a Day Turns Fear Into a Reflex

Discipline, in the end, is repetition, not knowledge. The routine is three pieces: two minutes in the morning, five before you leave, ten a week. The morning piece is finding out where you are standing. Run status to see if the tree is clean, and the last five lines of log to see where you are. Much of the fear of git comes from not knowing where you are standing, and two minutes of checking removes it. If status shows several uncommitted changes, that is a signal: you left yesterday half-done. Finish it and commit, or stash it; once you choose, the day starts from a known state instead of a mystery.

The evening piece leaves the last checkpoint of the day. Commit what is worth keeping, push if you have a remote, and reread the last ten commits. If you cannot see what you did today, the commits are too coarse. If you cannot tell what each commit did, the messages are too thin. Push when things are stable, and push before big changes: the remote is the real backup, and the local repo is only a copy on one disk.

The weekly piece trims the repo. Delete dead branches, clear old stashes, prune remote branches. A repo you never trim becomes a place with many names: branches, tags, stashes, history all accumulate, until one day you do not know where you are. And remember: "it is gone" is almost always wrong. git records every move of HEAD in the reflog and keeps roughly 90 days of it by default. You deleted a branch or lost a commit mid-rebase: open the reflog, find the commit, confirm it, and make a new branch at it. The reflog is the local last safety net, and knowing it is there removes a lot of the fear of experimenting.

Put it all together and the argument is simple. For a solo developer, git is not a backup; it is a timeline you can ask questions of. Commit at checkpoints, experiment in branches, and write the reasons into history, and the three daily costs disappear. Discipline starts as rules and ends as reflexes. If you want to go deeper, the 34-page ebook The Version Control Discipline collects the full treatment.
