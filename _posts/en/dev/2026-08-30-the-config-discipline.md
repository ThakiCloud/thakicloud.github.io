---
title: "Config Incidents Leave No Trace in Git"
excerpt: "A code bug that fails review or tests never reaches production. A config value does not even reach the review table. This piece gives every value a home through four questions, keeps exactly one path for production changes, and shows how a diff on every deploy stops drift from growing."
seo_title: "Preventing Config Incidents: Treat Environment Settings and Secrets Like Code"
seo_description: "Why production config incidents never show up in git history, and a practical method for deciding where each value lives, keeping one change path, and catching drift with a ten-minute weekly check."
date: 2026-08-30
last_modified_at: 2026-08-30
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - config-management
  - secrets-management
  - devops
  - environment-drift
  - feature-flags
  - incident-response
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/the-config-discipline/"
ebook: /assets/ebooks/the-config-discipline.pdf
ebook_title: "The Config Discipline"
ebook_pages: 33
---

If you run a cloud service yourself and your chest tightens every time you have to touch one environment variable, this piece is for you. The conclusion first: config incidents are expensive not because a value is wrong, but because the value never went through the gates your code goes through, review, tests, and the pipeline. That is why the cause is not in the git history, and there is no way to roll it back.

Saturday, 11:30 p.m., an alert says the payment confirmation emails are not going out. You shipped at 9 p.m. like always and CI was green. Only production went quiet. The cause is one line. A small refactor the day before renamed the environment variable that carries the email-sending secret, but production still held the value under the old name. The server did not crash. It simply stopped talking. The story is a composite of incident patterns that repeat in the same shape.

Code bugs and config incidents are born at different moments. A code bug that fails review or tests does not reach production. A config incident does not sit at the review table at all. One environment variable survives as somebody's console click. No matter how carefully you dig through the history, the cause is not there. The cause lives outside the history, in the world of values.

![Illustration of the core idea of Config Incidents Leave No Trace in Git](/assets/images/the-config-discipline-hero.webp)
*A visual metaphor for the article's key idea.*

## The Four Faces of a Config Incident

Config failures usually wear four faces. The first is drift: the values differ a little between environments. A timeout of 2 seconds in development, 30 in staging, 300 in production, and nobody knows who set it, when, or why. When you finally fix the value, you overwrite another environment's value without knowing it was there. The difference opens slowly, so nobody finds it strange.

The second face is secret leakage. A database password left in git history, a connection string printed into an error log, an account visible in a screenshot. The problem is not the leak itself, it is that the value keeps working after the leak. The value does not die. You only have to forget it.

The third is environment confusion. Staging and production share the same secret, so the casual "try it on staging first" becomes a touch of production data. Having no boundary does not mean having no mistakes; it means the door for mistakes is always open.

The fourth is coupling with deploys. Code and settings always move together, so changing one value needs a deployment that drags along things you did not intend. The values that should change stay frozen, and the values that should stay frozen keep wobbling.

The four faces share one trait: discovery comes late, and the bill arrives only after the effect has reached a customer. Config incidents happen quietly.

## The Real Cost Is Daily Friction

The price of configuration does not arrive only as outages. Outages are visible, almost worth being grateful for. The pricier cost is the daily friction, and the most common is verification time: not knowing where a value lives costs you five, ten, or forty minutes at a time. Small per hit, but three hits a day for a month becomes a fixed tax on the team. A solo operator with about twenty values, spending thirty to sixty minutes a week just locating things, is a common level [estimate].

The second friction is onboarding. A new person needs a map of the values before the codebase: which environments, which values injected where, where the secrets live. If that answer is not written down, onboarding runs on word of mouth, and word of mouth breaks the day one person leaves.

The third friction is anxiety. The feeling before you change one environment value or add one secret: will this touch another environment, who else knows this value, what will break in ninety days. That anxiety is a symptom of a missing system; a system does not make it disappear, but it shrinks it into something you can check.

The cost is not set by the number of values alone. It is the number of environments times the number of values. Ten values across two environments is twenty combinations; across five, fifty. A solo operator usually benefits more from trimming environments than from trimming values.

## Give Every Value a Home

The first step against that friction is deciding where every value your app consumes belongs. Values fall into four layers. Constants are the same in every environment and never change at runtime, a default page size, a retry count. Environment settings differ per environment but are harmless if known: a database host, a log level, an external endpoint. Secrets grant access or enable forgery the moment they leak: passwords, API tokens, signing keys. Feature flags switch the behavior of a service without a deploy.

The decision procedure is four questions. First: does the value differ per environment? If yes, an environment setting. If no, a constant, but the same today is not the same forever. One more region next quarter and it differs. The only benefit of a constant is readability, so when unsure, hand it to environment settings.

Second: does leaking it cause damage? If yes, a secret. Even without immediate damage, a value can become half of a key when combined with another. An admin username looks harmless on its own, but paired with the password, half of the attack is already done.

Third: must it change without a deploy? If so, a feature flag. Environment settings can change at runtime too, so look at the cycle. Once a month is a setting; several times a week is a flag. If the cycle is unclear, keep it as a setting and watch.

Fourth: does it differ per person or per tenant? Then it is data, not configuration. If every customer uses a different payment gateway, lifting that into an environment variable adds one variable per customer, and every new variable makes the procedures heavier.

Misplacements also come in four shapes: committing a secret into a .env file, freezing a feature on/off as a code constant, lifting tenant values into environment variables, and locking non-sensitive values into the secret store. When a value sits in the gray zone, first ask whether it splits in two. An endpoint and its token are two values with two different cycles; glued together, the short-cycle value drags the long-cycle one around. A layer decides the place, and a place removes the search.

## One Path for Production Values

Once every value has a home, the next step is the change path. Production values must be able to change through exactly one path, and that path is the pipeline. Close the door to logging into the console and editing by hand. If an exception is truly unavoidable, record it: when, who, why, which value, same day, and merge the same change into the pipeline next week. A pile of exceptions is a drift list by another name.

Put the two paths side by side.

| | Console edit | PR and pipeline |
|---|---|---|
| Review | none | yes |
| Rationale | somebody's head | written in the PR |
| Diff | none | snapshot versus snapshot |
| History | none | stays in git |
| Rollback | relies on memory | a PR that reverses one value |

Take raising a production timeout from 300 to 600. In the console it takes thirty seconds. In this structure it is different: edit the production config file and open a PR, the reviewer reads one line and asks why 600, on merge the pipeline injects 600, and after the deploy the new snapshot is diffed against the old one. The diff should show exactly that one line. Thirty seconds becomes five steps; the thirty-second version has no review, no rationale, no diff, no record. The structure pays for itself the next time someone raises that value again, because finding the history then takes seconds.

The environment files themselves live in the repository, like code. Values are split into a directory per environment, and secrets are excluded. Secrets sit in the manager, and the pipeline injects them at deploy time. The easy miss in this structure is that environments share keys, not values. The key list the app reads is defined once, and every environment fills it in.

A key that is not filled in must fail at startup. If one required key is missing, the app dies, and dying is good. If a key is missing in production, the app either dies or keeps running on the wrong value and keeps making money. A missing setting that shows up as a startup failure beats one that disguises itself as behavior. The opposite pattern is the silent default. One line that falls back to a hardcoded value when the key is absent quietly makes every environment that skipped injection use the same value. Development's two seconds become 300; staging's thirty become 300. A default erases the difference between environments, and the erased difference returns later as an outage.

## Secrets Are State, Not Values

Of the four layers, secrets need the most careful hands. A secret is a value that grants access or enables forgery if it leaks, but it is closer to state than to value. Rotating it means the old value and the new value coexist for a while. Half the fleet on the new value, half on the old, and only the inventory can tell which one is still valid.

Secrets usually leak through five roads: the git commit, the log, the screenshot, the document, and the dead code. A value that sat in history once is not gone when you delete it from the current file; from the moment history is rewritten, treat it as already leaked. Debug mode that dumps the whole environment. Tokens riding in error messages. Console screenshots pasted into a pull request. Runbooks that say for example and then paste the real key beside it. Documents outlive code; the code changes, but the document keeps last year's value.

So adding a secret is a set of three actions: write the name in the example file, put the value in the secret store, and add one inventory row with name, owning service, expiry, last rotation date, storage location. Skip the three actions and the value becomes a candidate for the next incident.

Separate the keys per environment for the same reason. The smaller the team, the stronger the temptation to share one key to save money. Shared keys stop rotation: one change now means updating every environment in lockstep, and any environment that lags keeps the old key working. Shared keys also hide the cause of an incident and blur the blast radius: with the same key, you cannot tell whether a suspicious connection in production logs came from development.

When a value turns out to have leaked, order matters. Do not start with the investigation. While it takes hours, the old value is still a working key. Invalidate first. Then scope it: git history, the log service, the error tracker, and everywhere the value was shared, written down in time order. Invalidate any other service or account that used the same key. Write the record even if nothing was damaged, and finally put a guard on the road the value came out through. A secret that lands in a public repository is found by scanners in minutes; if finding takes minutes, assume using takes minutes.

## Ten Minutes a Week Catches Drift

Everything above compresses into one line: give every value a home, keep one path for production, and read the diff on every deploy. Drift is not intentional. It is a value changed a little and forgotten, an environment that never followed. An intended-but-unrecorded change is a candidate, not drift yet. The line between candidate and fact is one question: does the change show up in the next deploy's diff?

If the diff shows only the change from the intended PR, the system is alive. If it shows something else, it usually came from three places: a console edit, a value that never followed a rotation, and somebody's temporary fix. Temporary fixes are the dangerous ones. A value added to stop an incident can survive after the incident ends. If the reason is never written down, the value stays forever, and the value that stays forever is the start of the next incident.

What makes the diff cheap is the snapshot. At deploy time, record the values that actually got applied, masked where secrets sit, and compare with the last snapshot. Any difference that is not your PR is drift, standing still. Without the diff, the inventory just accumulates and nobody reads the pile. An unread diff is the same as no diff.

Then, once a week, on the same day, spend ten minutes. Check the secret inventory for rotations due within a month. Check the active flags for owners and deadlines. Check the production change audit for anything outside the pipeline. Check that staging and production still pass the schema check. If any of the four comes back as unknown, spend thirty more minutes that week. Stacked unknowns are drift; keeping everything checkable is the state where drift cannot form.

Configuration discipline is repetition, not talent. Four questions per value, three actions per secret, one path for production, one diff per deploy, ten minutes per week. Run that loop three times and the answer to "where does that value live" gets faster. You can start tonight: list every environment variable the app reads, and fill in three columns next to each. Does it differ per environment? Is it sensitive? Has it changed in the last month? Any value with an unknown is the one to touch first this week; not knowing means the value belongs to no system yet.

If you want the full procedure rather than the argument, the e-book The Config Discipline extends this piece: the five-step leak response, the flag lifecycle, and the quarterly leak drill, in 33 pages.

## References

- Configuration as values injected per environment: [The Twelve-Factor App](https://12factor.net/)
- Configuration drift and how to detect it: [AWS, What is Configuration Drift](https://aws.amazon.com/what-is/configuration-drift/)
- Detecting leaked secrets in public repositories: [GitHub, About secret scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
