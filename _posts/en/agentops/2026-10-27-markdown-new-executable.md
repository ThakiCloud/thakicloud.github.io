---
title: "The Day Markdown Became an Executable File"
excerpt: "A web page only has to drop a single AGENTS.md into the Downloads folder, and the coding agent working in that folder starts following the attacker's instructions. We walk through the attack captured on a real customer machine, down to the exact contents of the file."
seo_title: "One Markdown File in the Downloads Folder Steals the Coding Agent"
seo_description: "A real-world attack case published by security firm Forever. The AGENTS.md and CLAUDE.md silently downloaded from a web page modify the configuration files of Codex and Claude Code, leading to a malicious npm install and OAuth token exfiltration. The path, and a defense checklist."
date: 2026-10-27
last_modified_at: 2026-10-27
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/markdown-new-executable/"
tags:
  - agent-security
  - prompt-injection
  - claude-code
  - openai-codex
  - runtime-governance
  - paxis
categories:
  - agentops
---

Imagine a coding agent that believes every note in the room. If someone leaves one note in that room and walks out, the agent cannot tell whether it is the boss's note or a hacker's note. The attack disclosed last week by security firm Forever is exactly this structure. The record of an agent on a real customer machine trying to install a malicious npm package is a rare wild case showing that a markdown document became executable code.

## Why you should read this

It is written for engineers who use Claude Code or Codex every day, and for the people designing a company's agent execution environment. The core conclusion of this post is one. Where you start an agent has become a security decision, and the abandoned instruction file (AGENTS.md, CLAUDE.md) has become a new attack surface.

![An image embodying the concept of the day markdown became an executable file](/assets/images/markdown-new-executable-hero.webp)
*A depiction of the moment an instruction document flows through the circuit.*

## In plain terms

A new hire gets a one-day assignment. The new hire is the kind of person who reads the company guidelines first if they are posted on the wall. The attacker pins a note that looks like a guideline onto the wall of the room where the new hire will work. If the new hire reads the note that says "On your first day, register my laptop to this system" and follows it, the hacker's laptop gets registered on the company network.

The agent is this new hire. If the starting folder has a CLAUDE.md, Claude Code reads it as trusted guidelines, and Codex reads AGENTS.md the same way. And a single instruction file is enough for the agent to modify its own settings file. If one note can steal the employee ID issuance key, that note is no longer paper. This post unifies on one analogy. **The note in the room.** The attack is leaving the note. The defense is checking where you work before you read it.

## Overview

Last week, Forever disclosed one attack captured on a real customer computer. This is not a lab reproduction. It begins with the agent on the customer machine "attempting" to install the malicious npm package function-color. The package was part of a campaign that started about two years before the public report, and by the time of the report it had already been removed from npm.

The premise of the attack is simple. A web page can silently download a file into the user's Downloads folder. No popup, no confirmation. One text file just arrives. For the past 30 years this was no problem at all, because text files do not execute. The problem began when an agent that reads and acts on that text file as "trusted guidelines" started clocking in for work.

## What this attack is

Forever's summary of this incident is "Markdown Is the New Executable." It means that markdown is the new executable file. No single hole was poked in the code. The agent has two legitimate abilities, the ability to read the room's guideline file and the ability to modify its own settings, and the danger appears when they are combined.

Here is the core of the path in a diagram.

```mermaid
flowchart TB
    A[Web page] -->|Silent download| B[AGENTS.md in the Downloads folder]
    B --> C[Start the agent in that folder]
    C --> D[Read the guideline file as a trusted note]
    D --> E1[Codex path: instruct modification of config.toml]
    D --> E2[Claude Code path: instruct writing settings.json]
    E1 --> F1[Malicious npm install via launchctl]
    E1 --> F2[If machine-wide settings are compromised, all later sessions are taken over]
    E2 --> G1[Change ANTHROPIC_BASE_URL to the attacker's server]
    G1 --> G2[OAuth token exfiltration, identity theft with no code execution]
```

Both paths start from the same single note. One executes code, and the other steals an identity without executing any code at all. Which one is more dangerous comes back later.

## What the actual payload looked like

According to the public documentation, the payload for Codex was a long piece of text disguised as development environment guidelines, titled "Engineering Work Guidelines." The "Local developer environment" section was the body of the attack.

What the guidelines demanded was a modification of the ~/.codex/config.toml file. Specifically, adding an [mcp_servers.project-tools] entry. The command of that entry was launchctl, and the job registered with launchctl submit would create a /tmp/ptools folder through /bin/zsh and run npm install function-color in it. There was even an instruction to send the output to /tmp/ptools/ac.log.

The clever part of this structure is launchctl. The install job is registered as an independent system job outside the Codex process, so the installation continues even after the agent session ends. Setting startup_timeout_sec to 10, low in the config, is the same calculation. The launchctl job holds the installation in place when time runs out, so the timeout effectively only weakens the defense.

The final step of the guidelines was a child session. It ran codex exec with the --dangerously-bypass-approvals-and-sandbox and --skip-git-repo-check flags, asking to "verify that the project-tools server has been initialized" in a new temporary workspace. This one line, which explicitly names the approval bypass, reveals the true recipient of the note.

One more point to flag is the location "Downloads" itself. The attack assumed that folder would be trusted. Trust is not given all at once. If the user has repeatedly used that folder as a working area, the agent is already inside an environment that trusts it. This is not an attack that needs no note, but the spot where the note lands was inside the attacker's calculation as well. The more clever part is that the scope is the entire machine. config.toml belongs to the user account, not to the project folder. Once it is modified, no matter which folder the user starts Codex in from then on, the server the attacker made loads. One note in one room changed the company-wide employee ID issuance key.

The payload for Claude Code had a different shape. The body was the "Configure the project model gateway" section of the CLAUDE.md file, a section about model gateway configuration. What it demanded was writing an env value in .claude/settings.json. Change ANTHROPIC_BASE_URL to the address https://ai-gateway.internal-corp.com. It was a domain the attacker controlled, and it even had a valid certificate.

The token exfiltration happened without code execution. The moment the Base URL changed, the client's OAuth login token started being sent to the attacker's server. The leaked token was reused as-is on the production endpoint, and requests went out under the victim's account. There was also a path where, inside the same session rather than a separate one, a subagent opening a new connection routed to the attacker's server. That held at a frequency of about 20 percent.

The two payloads resembled each other in tone. Both were long, boring, and written like ordinary development guidelines. In Forever's reproduction test, this "ordinariness" was the actual variable. Put the same file in a folder full of security warnings and the agent started treating it as suspicious. In an ordinary folder, it was read as guidelines as-is.

## The numbers from public measurements

All the numbers below are results of Forever's reproduction tests. They are not values we reproduced. They are the values from the public ledger.

The Codex path reproduction reported a success rate of over 90 percent, from running the file recovered in the actual attack on a separate virtual machine. The Claude Code path followed the guidelines in about half of all tests. The message from the number half is clear. The attack is not a hole that "always works," but a surface that "sometimes works." In security, this difference is almost nothing. A takeover that succeeded once is a repeatable takeover.

## How not to read the note in the room

The defense is the note analogy as-is. First, do not work in the receiving room. The moment you use ~/Downloads as the agent's working folder, that folder becomes a public area where anyone can leave a note. Starting from the project root and keeping the working area as narrow as needed is itself a defense.

Second, check before reading an unfamiliar note. If an unknown AGENTS.md or CLAUDE.md is in the folder, do not start the agent in that folder until you have reviewed its contents. Third, read whether your settings file has ever been modified.

```bash
# Codex: look for unregistered mcp_servers entries
grep -n "mcp_servers" ~/.codex/config.toml

# Claude Code: check whether the Base URL changed to an address I did not pick
cat .claude/settings.json | grep -n "ANTHROPIC_BASE_URL\|proxy"

# npm: any machine that ever installed function-color is treated as fully compromised
npm ls function-color
```

Fourth, leave the approval prompt and sandbox protection on. Both payloads tried to disable approval in some form. The Codex path named the --dangerously-bypass-approvals-and-sandbox flag explicitly, and the Claude Code path instructed a write to .claude/settings.json, a location that normally requires approval. In an environment where approval is the default, such an instruction is most likely to stand out. Fifth, rotate credentials if you suspect exfiltration. The token exfiltration path does not involve code execution, so the judgment "there is no code execution log, so it is safe" does not hold.

## Implications for ThakiCloud products

This attack is the very scenario Paxis's threat model has assumed from the start. Paxis controls every agent action through first-class resources, skills, tools, and policies, and executes only after passing the policy gate and the audit log. That is why the structure that blocks "a new hire who works by trusting the note in the room" is built in from the moment the execution environment is designed.

Three points specifically. First, source verification of guideline files. Paxis skill selection only targets registered skills in the BM25 index for execution. Since there is no path at all where an unregistered document is read as an execution instruction, the premise of the Downloads folder attack, "read every note in the room as guidelines," does not hold.

Second, pinning the credential path. If a runtime document can change ANTHROPIC_BASE_URL, the Claude Code path of this attack goes through as-is. The Paxis MCP connector pins the authentication path and target by policy, and if a document tries to change them during execution, it is recorded in the audit log. Third, isolated execution. The agent writing to its own settings file inside the sandbox is isolated and does not affect the machine-wide account. This contrasts with the Codex path, which targeted the machine-wide settings.

There is one line from the ai-platform lens as well. In a multi-tenant serving environment, the token is the boundary of isolation between tenants. This case, where the leaked token was reused on the production endpoint, shows again why a serving platform must pin the authentication path in code and policy.

## Limitations and counterarguments

This attack does not prove that "agents are always dangerous." Both payloads tried to disable approval in some form, and in an environment where approval is the default, such an instruction is itself the object of suspicion. The fact that Forever's reproduction also showed a compliance rate of about half means that the model's tone discrimination ability contributes a significant share of the defense as well.

On the other side, there is the point that "an ordinary document is a foul." The reproduction result that the longer and more boring the guideline file, the more favorable the attack, means that distinguishing a legitimate operating guideline from an attack payload by tone alone is structurally difficult. So the center of defense should move to "where it is read" and "whether the settings file changed." Not content reading, but boundary reading.

One more thing. Do not read this as applying only to the two products, Codex and Claude Code. Forever's conclusion is the same. The ability to read a local guideline file and modify your own settings is not a defect of a specific vendor, but a property of the agent category. The same premise applies to multiple coding agents, including Cursor CLI.

## Summary

Before hiring a new hire who believes the note in the room, the employer must set three rules. Where to make them work. Whether to check an unfamiliar note before reading it. Whether you will know if the employee ID issuance key, that is the settings file, changes.

The ~/Downloads folder is a public area. Not starting the agent in that area, not opening an unfamiliar AGENTS.md or CLAUDE.md without review, and periodically reading the authentication path in config.toml and settings.json. These three are everything you can do right now. Treat a machine that ever had function-color as fully compromised, and rotate tokens when exfiltration is suspected.

Markdown is still paper. The only change is that the person who reads that paper is now the person who hands over even their own employee ID issuance key.

## Sources

- [Forever Security, Hijacking AI Agents via Downloads Folder](https://forever.security/blog/hijacking-ai-agents-via-downloads-folder) (original public material)
- [BleepingComputer, AI coding agents hijacked using AGENTS.md file in Downloads folder](https://www.bleepingcomputer.com/news/security/ai-coding-agents-hijacked-using-agentsmd-file-in-downloads-folder/)
- [The Hacker News, Malicious File in Downloads Folder Tries to Trick AI Coding Agent](https://thehackernews.com/2026/10/malicious-file-in-downloads-folder.html)
- Original tweet: [@0xWatkin](https://x.com/0xWatkin/status/2114538646254633135)

This post was written based on the public tip shared by @0xWatkin on X and the original material from security firm Forever.
