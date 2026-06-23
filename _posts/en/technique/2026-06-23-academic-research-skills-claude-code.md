---
title: "13 Agents Write a Paper Together: Integrating Academic Research Skills into Our Stack"
excerpt: "From literature search to submission-ready manuscript, we connected a 10-stage pipeline automatically using a Claude Code skill pack and integrated it into the ThakiCloud agent environment. We explain what the design of 13 research agents, two rounds of peer review, and 100% citation verification actually means, and where the verified-only principle meets our platform philosophy."
seo_title: "Academic Research Skills Integration - Claude Code 13-Agent Paper Pipeline | Thaki Cloud"
seo_description: "A hands-on account of integrating the Academic Research Skills pack into the ThakiCloud agent platform: deep-research with 13 agents, academic-paper writing pipeline, two-stage peer review, and Semantic Scholar citation verification, with notes on multi-tenant implications."
date: 2026-06-23
last_modified_at: 2026-06-23
categories:
  - technique
tags:
  - ai-agents
  - claude-code
  - research-automation
  - multi-agent
  - skills
  - llmops
lang: en
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "graduation-cap"
header:
  image: /assets/images/academic-research-skills-claude-code-hero.png
canonical_url: "https://thakicloud.github.io/en/technique/academic-research-skills-claude-code/"
---

![Abstract image of a research assembly line](/assets/images/academic-research-skills-claude-code-hero.png)
*A staged pipeline flowing from research to manuscript, passing through gates at each transition.*

## Overview

The performance of a coding agent is increasingly determined not by the model itself but by the skills and workflows layered on top. The same model becomes an entirely different specialist depending on which skill pack is loaded. In June 2026, a project that pushed this idea to its limit in academic research gained attention. It connects 10 stages automatically, from literature search to a submission-ready PDF manuscript, with agents playing the roles of supervisor, three peer reviewers, and copyeditor.

ThakiCloud runs a Kubernetes-based AI/ML SaaS platform serving agent workloads for multiple customers simultaneously. The design principle of "multiple agents collaborating to produce verifiable output" is not someone else's problem for us. This post is a record of actually integrating that skill pack, Academic Research Skills, into our agent environment and examining its architecture. Rather than a promotional overview, we look at what is inside, how much of it can be trusted, and what is genuinely useful from our platform perspective.

## What This Skill Pack Is

Academic Research Skills is a noncommercial skill collection for Claude Code that packages research, writing, verification, review, editing, and citation-integrity workflows into step-by-step skills, agents, and gates. The core is not a single prompt but the **collaboration of multiple specialized agents** and **mandatory verification gates between each stage**. It is organized into four major skills.

- **deep-research** (version 2.9.4): A 13-agent research team that handles any topic. It supports 7 modes: full research, quick brief, paper review, literature review, fact-checking, Socratic guided dialogue, and systematic review with meta-analysis. Roles are divided across research-question formulation, methodology design, systematic literature search, source verification, cross-synthesis, bias-risk assessment, APA 7.0 report writing, editorial review, and devil's advocate counterargument.
- **academic-paper**: A writing pipeline that produces actual paper output from research findings. It accepts a style profile, applies it, and runs a writing-quality check immediately before drafting, flagging AI-typical overused phrases, monotonous sentence length, and padding in introductions.
- **academic-paper-reviewer**: Serves as the reviewer who assesses a completed manuscript.
- **academic-pipeline** (version 3.11.1): The orchestrator that ties all three together. It does no work itself; it only handles stage detection, mode recommendation, skill dispatching, and status tracking. A thin conductor.

The 10 stages the orchestrator connects are as follows.

```text
[1] RESEARCH
      |
[2] WRITE
      |
[2.5] INTEGRITY <- 100% citation and data verification gate
      |
[3] REVIEW (first peer review)
      |
[4] REVISE
      |
[4.5] RE-REVIEW (second focused review)
      |
[5] RE-REVISE
      |
[5.5] FINAL INTEGRITY (re-verification)
      |
[6] FINALIZE (PDF with provenance record)
```

Two design decisions here are particularly interesting from a ThakiCloud perspective. First, both core skills explicitly declare `data_access_level: verified_only` in their metadata. Second, there is a **mandatory verification gate** between each stage. Claims about the literature are not generated from the model's memory; they are checked against an actual paper database via the Semantic Scholar API. Instead of producing plausible-sounding citations, citations that do not exist are blocked at the gate.

## Installation and Integration

Installation was done by cloning the external repository and linking it into our `.claude/skills/` directory via symbolic links. Rather than maintaining a separate copy, we follow the source so upstream updates are reflected automatically.

```bash
# Clone the external repo (home directory)
git clone https://github.com/Imbad0202/academic-research-skills.git ~/academic-research-skills

# Link into our agent skills directory
cd .claude/skills
ln -s ~/academic-research-skills/deep-research            deep-research
ln -s ~/academic-research-skills/academic-paper           academic-paper
ln -s ~/academic-research-skills/academic-paper-reviewer  academic-paper-reviewer
ln -s ~/academic-research-skills/academic-pipeline        academic-pipeline
```

Checking which skills are connected after linking shows them resolved as symlinks:

```text
academic-paper          -> ~/academic-research-skills/academic-paper
academic-paper-reviewer -> ~/academic-research-skills/academic-paper-reviewer
academic-pipeline       -> ~/academic-research-skills/academic-pipeline
deep-research           -> ~/academic-research-skills/deep-research
```

Internally at ThakiCloud, we wired these four skills into our research and report pipeline (the jarvis family) so that paper-oriented inputs invoke deep-research in paper-review or literature-review mode. The "full review document (DOCX)" output attached to the paper-category posts on our blog also sits on the same philosophy of verification-first review.

## What Is Actually Inside

Opening the orchestrator's agent configuration directly reveals not a simple bundle of prompts but agents with clearly separated roles.

```text
academic-pipeline/agents/
+-- pipeline_orchestrator_agent.md      # stage switching and dispatch
+-- state_tracker_agent.md              # progress state and checkpoint tracking
+-- integrity_verification_agent.md     # citation and data integrity verification
+-- collaboration_depth_agent.md        # records depth of human-AI collaboration
+-- claim_ref_alignment_audit_agent.md  # claim-citation alignment audit (L3)
```

Several safeguards stand out.

- **Integrity verification stages (2.5, 5.5)**: Citations and data are verified 100% twice, once after writing before review submission, and once after revision is complete. Failing this gate blocks progression to the next stage.
- **L3 claim-citation alignment audit**: Enabling the `ARS_CLAIM_AUDIT=1` flag adds a claim-fidelity audit gate at the transition from stage 4 to stage 5. It collects and classifies unsupported assertions, claim drift, and constraint violations, and if the risk level is high enough the formatter refuses to produce output. Off by default, designed to be enabled gradually as calibration data accumulates.
- **Material Passport**: Enabling `ARS_PASSPORT_RESET=1` promotes stage checkpoints to context-reset boundaries. In a new session, you can resume from a recorded stage using `resume_from_passport=<hash>`. This is a practical mechanism for cutting long tasks at stage boundaries to avoid bloated context windows.
- **Provenance record PDF**: After the pipeline completes, it automatically generates a document recording how humans and AI collaborated. This makes it possible to trace "how far AI was involved" from an academic integrity perspective.

The README is provided in English, Japanese, Simplified Chinese, and Traditional Chinese, showing broad consideration for multilingual users. The license is noncommercial, so if you are evaluating commercial adoption, review the license terms first.

## Application to ThakiCloud K8s AI/ML SaaS Platform and Implications

The aspect that resonated most from integrating this skill pack is that it overlaps precisely with two principles we have emphasized in our platform design.

First, **verified-only and hallucination blocking**. ThakiCloud serves customers with significant on-premises and self-hosting requirements. In such environments, the most feared failure mode is "plausible but wrong output." The way Academic Research Skills cross-checks citations against an actual database rather than the model's memory reflects the same mindset as our internal rule of "only cite URLs you actually retrieved, mark unverified figures as estimates." The structure of code enforcing gates while models only generate content also resembles our principle of delegating format and verification in batch outputs to deterministic code.

Second, **the thin conductor and thick skills, with loops closed by verification**. academic-pipeline does no work itself; it handles only stage detection, dispatch, and status tracking. Real capability is packed into each specialized skill. Inserting an integrity verification stage twice before merging multi-agent fan-out results is the same conclusion as our operational lesson that hallucinations accumulate when parallel agent results are merged without a verification gate.

From a platform product perspective, this kind of research pipeline is well-suited to run as a multi-tenant workload on our Kubernetes infrastructure. In an environment where Kueue manages the GPU queue and vLLM serves models, spinning up isolated research agent teams per customer to produce verified reports limited to internal documents and internal data is a natural scenario. For public institutions and research organizations that cannot upload sensitive research materials to an external SaaS, the ability to run an agent pipeline with built-in verification gates inside their own infrastructure becomes straightforward differentiation.

## Limitations and Counterarguments

Good design, but not something to accept uncritically. There are several clear limitations.

- **Verification gates have a cost.** Running integrity verification twice across 10 stages, plus an optional claim audit, adds substantial tokens and time to each output. For cases where a quick draft is needed, this is overkill. That is why a quick-brief mode exists separately, and forcing the full pipeline on every task is not wise.
- **Semantic Scholar verification is not comprehensive.** Recent preprints not yet indexed in the database, non-English literature, and grey literature may fall outside verification scope. "Verified" does not guarantee 100% accuracy.
- **The noncommercial license** is fine for internal experimentation but requires legal review before embedding in a product. If commercial redistribution is the goal, it cannot be used as-is.
- **Agent count does not scale linearly with quality.** Numbers like 13 or 12 agents are impressive, but the key question is whether each agent genuinely adds verification from a distinct perspective. Running the same prompt multiple times is not verification. This skill pack does separate roles clearly, which is good, but adopters should evaluate by "diversity of verification" rather than "number of agents."

In summary, Academic Research Skills is a solid reference for taking the idea of "producing verifiable academic output with multiple agents" to its logical conclusion. What matters to ThakiCloud is not the tool itself but the design principles: enforcement of verification through code gates, a thin conductor coordinating thick skills, and closing multi-agent results with verification. These principles apply not only to academic papers but directly to the multi-tenant agent platform we operate every day.

## Sources

- Academic Research Skills (GitHub): [github.com/Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills)
- Original introduction tweet (via @XAMTO_AI): [x.com/hjguyhan/status/2069051203229802756](https://x.com/hjguyhan/status/2069051203229802756)
- Installed versions: deep-research 2.9.4, academic-pipeline 3.11.1 (local check as of 2026-06-23)
