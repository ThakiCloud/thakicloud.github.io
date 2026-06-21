---
title: "Nature-Grade Figures and Polishing as Code: A Hands-On Report on Running nature-skills"
excerpt: "We cloned nature-skills, an open-source Claude skill package that bundles Nature-journal-grade scientific figure generation with academic polishing, and used nature-figure to render ThakiCloud serving data into a submission-grade two-panel figure. We measured everything down to 36 editable SVG text tags and lay out the implications from a vertical-PMF perspective on the skill marketplace."
seo_title: "nature-skills Academic Figure and Polishing Skill Hands-On Report - Thaki Cloud"
seo_description: "A hands-on report running the nature-skills (Yuan1z0825) Claude skill package. We render a submission-grade matplotlib two-panel figure at 600dpi using nature-figure's rcParams and PALETTE, and analyze editable SVG output plus academic vertical marketplace implications."
date: 2026-06-21
last_modified_at: 2026-06-21
categories:
  - dev
tags:
  - claude-skills
  - academic-writing
  - matplotlib
  - data-visualization
  - nature-figure
  - skill-marketplace
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
---

![Abstract image of multi-panel data curves and figure plates floating in an academic atmosphere](/assets/images/nature-skills-hero.png)
*Capturing the spirit of an academic figure skill that treats a figure not as a "pretty plot" but as a "visual argument."*

## Overview

The two tasks researchers most often hand to Claude Code are "make a figure for my paper" and "polish this English draft to journal level." Hand either to a general-purpose LLM and the output wobbles every time. Figures get arbitrary font sizes and colors; polishing rewrites sentences with no consistent rules. The open-source skill package nature-skills (Yuan1z0825/nature-skills) aims to demote that variability into a verified scaffold.

As it gained attention, some shared posts described it as having "20K+ GitHub stars," but the actual number I confirmed was far smaller, around 265 [estimated]. Star-count inflation is common, so in this article I evaluated its value not by stars but by the measured results of running the tool directly. This is an implementation report that clones nature-skills into the ThakiCloud environment and uses its nature-figure skill to render real serving data into a submission-grade figure.

## What This Tool Is

The actual composition I confirmed after cloning the repository was 12 skills under `skills/` (excluding shared modules). It covers the entire academic workflow: nature-figure (scientific figures), nature-polishing (academic polishing), nature-academic-search (literature search), nature-citation, nature-reviewer, nature-response (reviewer responses), and more. The license is MIT.

The star of this article, **nature-figure, is version 2.0.0**, and it has a router structure split into static and dynamic layers. The large design, API, pattern, and QA knowledge lives in on-demand reference files, and for each task it detects the backend (Python/R) and loads only the fragment it needs. This is exactly the same pattern as the progressive disclosure that ThakiCloud emphasizes.

The most impressive design is the **"figure contract."** Before writing any code, it forces you to fix a one-sentence core conclusion, the evidence chain, the archetype classification, the backend, and the journal/export contract first. The skill insists that "a figure is a visual argument, not an isolated pretty plot." It also puts backend selection behind a **blocking gate**. If the user does not specify Python or R, it asks "Python or R?" and stops. It reduces the degrees of freedom so the model cannot pick a default on its own.

![nature-figure routing diagram from Figure Contract through the backend gate to the QA contract](/assets/images/nature-skills-diagram.png)
*The flow defines the core conclusion, passes the Python/R backend gate, applies rcParams and PALETTE to export editable SVG/TIFF, and finishes with the QA contract.*

## Installation and Integration (Real Commands)

Verification ran in an isolated sandbox outside the repository and was cleaned up afterward.

```bash
# 1) Clone the external repository
git clone --depth 1 https://github.com/Yuan1z0825/nature-skills

# 2) Confirm the Python backend dependency (shared .venv)
.venv/bin/python -c "import matplotlib; print(matplotlib.__version__)"
# matplotlib 3.11.0
```

nature-figure's Python quick-start (`static/fragments/backend/python.md`) specifies the `rcParams` for submission-grade figures, and `references/api.md` defines a journal-friendly PALETTE. The core settings are as follows.

```python
mpl.rcParams.update({
    "font.family": "sans-serif",
    "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans", "sans-serif"],
    "svg.fonttype": "none",   # keep text inside the SVG editable
    "pdf.fonttype": 42,       # keep text in PDF as editable TrueType
    "font.size": 7,           # 7pt baseline unless it is a large slide panel
    "axes.linewidth": 0.8,
})
# PALETTE excerpt from api.md
P = {"blue_main": "#0F4D92", "red_strong": "#B64342", "neutral_dark": "#4D4D4D"}
```

The single line `svg.fonttype: "none"` is the key. A typical export converts text to outlines (paths), making the letters uneditable in Illustrator. This setting keeps text as `<text>` tags, so labels can be edited directly during the journal proofing stage.

## Real Experiment Results

Applying the skill's rules (rcParams, PALETTE) verbatim, I rendered data directly relevant to ThakiCloud into a figure. The subject is a two-panel figure comparing latency and throughput of GPU inference serving across batch sizes for FP16 versus INT8. The serving-curve numbers in the plot itself are schematic, while the **measured values are the meta-numbers captured during rendering**.

```
RENDER_MS=195.4
SVG_BYTES=24131
PNG_BYTES=254233          # 600 dpi
SVG_EDITABLE_TEXT_TAGS=36
PANELS=2 (a:latency, b:throughput)
RCPARAMS_FONT_SIZE=7.0
SVG_FONTTYPE=none
```

There are three key results. First, rendering the two-panel figure finished in about 195 milliseconds. Second, the 600dpi PNG was about 254KB and the SVG about 24KB, both lightweight. Third, and the most important verification: the generated SVG contained **36 `<text>` tags**. This is direct evidence that the "editable text" the skill promises was actually upheld. Had it been converted to outlines, the `<text>` tag count would be 0.

![A Nature-style two-panel figure comparing FP16 and INT8 inference latency and throughput](/assets/images/nature-skills-results.png)
*The actual output rendered by applying nature-figure's rcParams and PALETTE. Left (a) shows latency by batch size, right (b) shows throughput. The serving-curve values are example data.*

These numbers were all captured to stdout by running it myself, not quoted externally. The key point is that the skill proves quality with execution evidence rather than claiming in prose that it "drew something pretty."

## Application and Implications for the ThakiCloud K8s AI/ML SaaS Platform

nature-skills demonstrates two threads at once.

From a data-science practitioner's perspective, the idea of **fixing chart style with verified tokens** is immediately useful. ThakiCloud's reports and dashboards tend to wobble in color, font, and axes every time, but pinning rcParams and PALETTE in one place like nature-figure raises the average quality. In particular, the pattern of exporting editable SVG with `svg.fonttype: "none"` can be used directly for marketing and seminar materials that the design team post-processes. The result figure in this article is the proof.

From a platform-strategy perspective, nature-skills shows a **PMF (Product-Market Fit) signal for the academic vertical**. Rather than a general-purpose skill, it condenses rules into the narrow, deep use case of "Nature journal submission," which is why the output is so consistent. For ThakiCloud, which operates a K8s-based AI/ML SaaS, a vertical skill that layers thin domain rules on top of a general-purpose LLM is a core differentiation pattern. The same scaffold can be replicated into in-house verticals such as healthcare, finance, and patents.

## Limitations and Counterarguments

First, **star-count inflation**. The "20K+ stars" in some shared posts differed greatly from the actual figure (around 265) [estimated]. This case reconfirms that you should not trust viral signals at face value and instead run the tool yourself.

Second, **responsibility for the truth of the figure data rests with the user.** The skill draws figures well, but it does not guarantee the accuracy of the numbers that go into them. That is exactly why I explicitly marked the serving curves as examples in this article. In a real paper or report, only measured values should go in.

Third, **the enforcement of the backend gate** can become friction in an automation pipeline. The behavior of asking "Python or R?" and stopping each time is a safeguard in interactive use, but unattended batches need a wrapper that fixes the backend in advance.

In conclusion, nature-skills is a good example of "a vertical skill that condenses domain rules into code." When you judge its value by measured evidence such as 36 editable text tags rather than by stars, its design has plenty worth learning from.

## Sources

- nature-skills (GitHub, MIT): [github.com/Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills)
- All measured numbers in this article were rendered locally by cloning nature-figure v2.0.0 directly. The star count (around 265) is an estimate based on a search.
